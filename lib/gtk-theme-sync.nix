# gtk-theme-sync：把 Noctalia 当前的深浅色模式镜像成 gtk-theme-name。
#
# Noctalia 的 gtk3/gtk4 模板只把主题名写进 dconf/GSettings；X11/XWayland 里
# 没有 XSETTINGS 的 GTK 应用只读 ~/.config/gtk-{3,4}.0/settings.ini，所以由
# Noctalia hooks 调用本脚本按模式补 gtk-theme-name。
#
# 光标不在这里处理：它固定为 theme.cursor-name，由 home.pointerCursor 声明式
# 写入 settings.ini 和 dconf（见 home/cursor-theme.nix）。
#
# 调用方式：
#   started            → --apply（向 Noctalia 查询当前模式）
#   theme_mode_changed → --mode "$NOCTALIA_THEME_MODE"
#   Home Manager 激活  → --apply（见 home/gtk.nix 的 gtkThemeSyncApply）
{ pkgs }:

let
  inherit (pkgs) lib;
  noctalia = lib.getExe pkgs.noctalia;
in
pkgs.writeShellApplication {
  name = "gtk-theme-sync";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.gnused
  ];

  text = ''
    noctalia_bin=${noctalia}

    usage() {
      printf 'usage: %s --apply | --mode {dark|light}\n' "$0" >&2
    }

    gtk_theme_name() {
      case "$1" in
        light) printf '%s\n' adw-gtk3 ;;
        dark) printf '%s\n' adw-gtk3-dark ;;
        *) return 1 ;;
      esac
    }

    # HM 生成的是只读 store 软链；落成本地可写文件后再补 gtk-theme-name。
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
      mode="$1"
      gtk_theme="$(gtk_theme_name "$mode")" || return 1
      for version in 3 4; do
        file="''${XDG_CONFIG_HOME:-$HOME/.config}/gtk-$version.0/settings.ini"
        materialize_ini "$file"
        set_ini "$file" gtk-theme-name "$gtk_theme"
      done
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
        ;;
      *)
        usage
        exit 2
        ;;
    esac

    write_gtk "$mode"
  '';
}
