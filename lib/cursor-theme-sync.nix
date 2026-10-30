# cursor-theme-sync：一次性把当前 Noctalia 深浅色模式应用到光标相关配置。
#
# 由 Noctalia v5 hooks 调用（home/noctalia.nix 注入 [hooks]）：
#   started            → cursor-theme-sync --apply
#   theme_mode_changed → cursor-theme-sync --mode "$NOCTALIA_THEME_MODE"
# Home Manager 激活后也调用一次 --apply，把被激活流程还原的 settings.ini
# 光标键补回去（不会写 GTK 主题色/color-scheme）。
#
# 只写光标相关的东西：
#   - ~/.config/niri/cursor.kdl（niri include 监听该文件）
#   - gtk-{3,4}.0/settings.ini 的 gtk-cursor-theme-name / gtk-cursor-theme-size
#   - dconf 的 cursor-theme / cursor-size
# GTK 主题名、prefer-dark、color-scheme 全部留给 Noctalia 的 GTK 模板和
# [theme].sync_color_scheme 管理。
{ pkgs, theme }:

let
  inherit (pkgs) lib;

  noctalia = lib.getExe pkgs.noctalia;
  cursorPackage = import ./cursor-package.nix { inherit pkgs theme; };
  dark = theme.cursor-name-dark;
  light = theme.cursor-name-light;
  alias = theme.cursor-alias;
  size = toString theme.cursor-size;
in
pkgs.writeShellApplication {
  name = "cursor-theme-sync";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.dconf
    pkgs.dbus
    pkgs.gnugrep
    pkgs.gnused
    pkgs.systemd
  ];

  text = ''
    noctalia_bin=${noctalia}
    cursor_package=${cursorPackage}
    dark_name=${dark}
    light_name=${light}
    alias_name=${alias}
    size=${size}
    alias_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/icons"
    alias_link="$alias_dir/$alias_name"

    usage() {
      printf 'usage: %s --apply | --mode {dark|light}\n' "$0" >&2
    }

    cursor_name() {
      case "$1" in
        dark) printf '%s\n' "$dark_name" ;;
        light) printf '%s\n' "$light_name" ;;
        *) return 1 ;;
      esac
    }

    # 稳定别名：XCURSOR_THEME 指向它，实际 dark/light 目标由这里切换。
    # 这样 niri 的 spawn 环境、已经启动的 Noctalia/shell 不需要改环境。
    write_alias() {
      cursor="$1"
      target="$cursor_package/share/icons/$cursor"
      mkdir -p "$alias_dir"

      if [ -e "$alias_link" ] && [ ! -L "$alias_link" ]; then
        printf 'error: %s exists and is not a symlink\n' "$alias_link" >&2
        return 1
      fi

      current="$(readlink -- "$alias_link" 2>/dev/null || true)"
      if [ "$current" = "$target" ]; then
        return 0
      fi

      ln -sfn -- "$target" "$alias_link"
      printf 'updated %s -> %s\n' "$alias_link" "$cursor"
    }

    # 首次登录、HM 激活时 Noctalia 可能还没就绪；先给别名一个 dark 兜底，
    # 后面 --apply 拿到真实模式会再改。别名缺失时桌面会找不到光标主题。
    ensure_alias() {
      if [ ! -e "$alias_link" ]; then
        write_alias "$dark_name"
      fi
    }

    # 只在内容变化时替换；mtime 不变的幂等保证。
    write_niri() {
      name="$1"
      dir="''${XDG_CONFIG_HOME:-$HOME/.config}/niri"
      file="$dir/cursor.kdl"
      mkdir -p "$dir"
      tmp="$(mktemp "$dir/.cursor.kdl.XXXXXX")"
      {
        printf '%s\n' '// 由 Noctalia hooks 调 cursor-theme-sync 生成，勿手改。'
        printf '%s\n' '// config.kdl 末尾 include optional=true "cursor.kdl"，niri 监听并自动重载。'
        printf '%s\n' 'cursor {'
        printf '    xcursor-theme "%s"\n' "$name"
        printf '    xcursor-size %s\n' "$size"
        printf '%s\n' '}'
      } >"$tmp"

      if [ -f "$file" ] && cmp -s "$tmp" "$file"; then
        rm -f "$tmp"
        return 0
      fi

      mv -f "$tmp" "$file"
      printf 'updated %s\n' "$file"
    }

    # HM 生成的是只读 store 软链；落成本地可写文件后再补光标键。
    materialize_ini() {
      file="$1"
      if [ -L "$file" ]; then
        target="$(readlink -f -- "$file")"
        if [ -n "$target" ] && [ -e "$target" ]; then
          cp --remove-destination -- "$target" "$file"
          chmod u+w "$file"
        else
          rm -f -- "$file"
        fi
      fi

      if [ ! -s "$file" ]; then
        mkdir -p "$(dirname -- "$file")"
        printf '%s\n' '[Settings]' >"$file"
      fi
    }

    # INI 键存在就替换，不存在就追加；内容没变则不碰文件。
    set_ini() {
      file="$1"
      key="$2"
      value="$3"

      if grep -qxF -- "$key=$value" "$file"; then
        return 0
      fi

      tmp="$(mktemp "$(dirname -- "$file")/.settings.ini.XXXXXX")"
      if grep -qE -- "^[[:space:]]*''${key}[[:space:]]*=" "$file"; then
        sed -E -- "s|^[[:space:]]*''${key}[[:space:]]*=.*|$key=$value|" "$file" >"$tmp"
      else
        cp -- "$file" "$tmp"
        if [ -s "$tmp" ] && [ -n "$(tail -c 1 -- "$tmp")" ]; then
          printf '\n' >>"$tmp"
        fi
        printf '%s=%s\n' "$key" "$value" >>"$tmp"
      fi

      cat -- "$tmp" >"$file"
      rm -f -- "$tmp"
      printf 'updated %s: %s\n' "$file" "$key"
    }

    write_gtk() {
      cursor="$1"
      for version in 3 4; do
        file="''${XDG_CONFIG_HOME:-$HOME/.config}/gtk-$version.0/settings.ini"
        materialize_ini "$file"
        set_ini "$file" gtk-cursor-theme-name "$cursor"
        set_ini "$file" gtk-cursor-theme-size "$size"
      done
    }

    # dconf 只写光标键；失败向上返回，不静默成功。
    dconf_set() {
      key="$1"
      value="$2"
      current="$(dconf read "$key" 2>/dev/null || true)"
      if [ "$current" = "$value" ]; then
        return 0
      fi
      if ! dconf write "$key" "$value" >/dev/null 2>&1; then
        printf 'error: dconf write %s failed\n' "$key" >&2
        return 1
      fi
      printf 'updated dconf %s\n' "$key"
    }

    apply_mode() {
      mode="$1"
      cursor="$(cursor_name "$mode")" || {
        printf 'error: invalid mode: %s\n' "$mode" >&2
        return 2
      }

      rc=0
      write_alias "$cursor" || rc=1
      write_niri "$cursor"
      write_gtk "$cursor"

      dconf_set /org/gnome/desktop/interface/cursor-theme "'$cursor'" || rc=1
      dconf_set /org/gnome/desktop/interface/cursor-size "$size" || rc=1

      # 环境里固定用别名；别名目标已切到当前模式。这样 systemd/D-Bus 新拉起的
      # 进程、以及 niri 已经启动的子进程环境都不需要随模式改写。
      systemctl --user set-environment \
        "XCURSOR_THEME=$alias_name" "XCURSOR_SIZE=$size" >/dev/null 2>&1 || true
      dbus-update-activation-environment XCURSOR_THEME XCURSOR_SIZE >/dev/null 2>&1 || true

      if [ "$rc" -eq 0 ]; then
        printf 'cursor-theme-sync: %s -> %s (alias %s, size %s)\n' "$mode" "$cursor" "$alias_name" "$size"
      else
        printf 'cursor-theme-sync: %s applied with errors\n' "$mode" >&2
      fi
      return "$rc"
    }

    resolve_mode() {
      output="$("$noctalia_bin" msg theme-mode-get 2>&1)" || {
        printf 'error: cannot query Noctalia theme mode: %s\n' "$output" >&2
        return 1
      }
      mode="$(printf '%s' "$output" | tr -d '[:space:]')"
      case "$mode" in
        dark | light) printf '%s\n' "$mode" ;;
        *)
          printf 'error: Noctalia returned invalid theme mode: %s\n' "$mode" >&2
          return 1
          ;;
      esac
    }

    case "''${1:-}" in
      --apply)
        if [ "$#" -ne 1 ]; then
          usage
          exit 2
        fi
        ensure_alias || exit 1
        mode="$(resolve_mode)" || exit 1
        ;;
      --mode)
        if [ "$#" -ne 2 ]; then
          usage
          exit 2
        fi
        case "$2" in
          dark | light) mode="$2" ;;
          *)
            printf 'error: invalid mode: %s\n' "$2" >&2
            exit 2
            ;;
        esac
        ensure_alias || exit 1
        ;;
      *)
        usage
        exit 2
        ;;
    esac

    apply_mode "$mode"
  '';
}
