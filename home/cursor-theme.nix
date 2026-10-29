# --- cursor ---
# Bibata Modern 两套重着色（lib/cursor-package.nix）：
#   dark  = 黑体白边   light = 白体黑边
# 与 config.kdl 的兜底 cursor 块同为 dark；GTK 侧由 home.pointerCursor 注入。
#
# 自动切换：cursor-theme-sync.service 轮询 noctalia 的解析后主题模式
# （noctalia msg theme-mode-get），变化时同时更新：
#   1. ~/.config/niri/cursor.kdl —— niri 的 include 监听该文件，重载后
#      合成器和它拉起的客户端都换用新主题（niri 自己会设置 XCURSOR_THEME）
#   2. ~/.config/gtk-{3,4}.0/settings.ini —— cursor 行、GTK3 主题名与
#      prefer-dark、GTK4 的 gtk-interface-color-scheme
#   3. dconf —— cursor-theme / cursor-size / gtk-theme / color-scheme，
#      供 portal 和会读 dconf 的 GTK 应用使用
#
# HM 每次激活都会把 settings.ini 还原成 store 软链，并可能覆盖 dconf，
# 所以主循环不只依赖 last 模式变化，每轮都校验实际文件/键是否仍匹配。
# 正在运行的 GTK 应用会缓存已加载的外观，切换后可能保持旧样式直到重启；
# 新启动的 GTK 应用立即使用新模式。
{ pkgs, theme, ... }:
let
  cursorPackage = import ../lib/cursor-package.nix { inherit pkgs theme; };

  cursorSync = pkgs.writeShellApplication {
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
      noctalia=${pkgs.noctalia}/bin/noctalia
      dark=${theme.cursor-name-dark}
      light=${theme.cursor-name-light}
      gtk_theme=${theme.gtk-theme}
      gtk_theme_dark=${theme.gtk-theme-dark}
      size=${toString theme.cursor-size}

      niri_dir="$HOME/.config/niri"
      niri_file="$niri_dir/cursor.kdl"

      cursor_name() {
        case "$1" in
          dark) printf '%s' "$dark" ;;
          light) printf '%s' "$light" ;;
          *) return 1 ;;
        esac
      }

      gtk_name() {
        case "$1" in
          dark) printf '%s' "$gtk_theme_dark" ;;
          light) printf '%s' "$gtk_theme" ;;
          *) return 1 ;;
        esac
      }

      # settings.ini 是 INI：存在就替换，不存在就追加。
      set_ini() {
        set_file="$1"
        set_key="$2"
        set_value="$3"
        if grep -q "^$set_key=" "$set_file"; then
          sed -i "s|^$set_key=.*|$set_key=$set_value|" "$set_file"
        else
          printf '%s=%s\n' "$set_key" "$set_value" >> "$set_file"
        fi
      }

      write_niri() {
        name="$1"
        tmp="$(mktemp "$niri_dir/.cursor.kdl.XXXXXX")"
        {
          printf '%s\n' '// 由 cursor-theme-sync.service 按 noctalia 深浅色生成，勿手改。'
          printf '%s\n' '// config.kdl 末尾 include optional=true "cursor.kdl"，niri 监听并自动重载。'
          printf '%s\n' 'cursor {'
          printf '    xcursor-theme "%s"\n' "$name"
          printf '    xcursor-size %s\n' "$size"
          printf '%s\n' '}'
        } > "$tmp"
        mv -f "$tmp" "$niri_file"
      }

      # home-manager 生成的 settings.ini 是只读 store 软链，先落成本地可写文件，
      # 之后写入当前模式的 cursor 与 GTK 深浅色键。下次 HM 激活还原软链后，
      # 主循环会通过 applied 检测到并再纠正。
      write_gtk() {
        mode="$1"
        cursor="$(cursor_name "$mode")" || return 1
        gtk="$(gtk_name "$mode")" || return 1
        for gtk_dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
          file="$gtk_dir/settings.ini"
          mkdir -p "$gtk_dir"
          if [ -L "$file" ]; then
            target="$(readlink -f "$file")"
            cp --remove-destination "$target" "$file"
          fi
          if [ ! -e "$file" ]; then
            printf '%s\n' '[Settings]' > "$file"
          fi
          # store 里的 settings.ini 是 0444，落成本地文件后要允许追加/改写
          chmod u+w "$file"

          set_ini "$file" gtk-cursor-theme-name "$cursor"
          case "$gtk_dir" in
            *gtk-3.0)
              set_ini "$file" gtk-theme-name "$gtk"
              if [ "$mode" = dark ]; then
                set_ini "$file" gtk-application-prefer-dark-theme true
              else
                set_ini "$file" gtk-application-prefer-dark-theme false
              fi
              ;;
            *gtk-4.0)
              set_ini "$file" gtk-interface-color-scheme "$mode"
              ;;
          esac
        done
      }

      dconf_ready() {
        dconf read /org/gnome/desktop/interface/color-scheme >/dev/null 2>&1
      }

      applied() {
        mode="$1"
        cursor="$(cursor_name "$mode")" || return 1
        gtk="$(gtk_name "$mode")" || return 1
        grep -q "xcursor-theme \"$cursor\"" "$niri_file" 2>/dev/null || return 1
        for gtk_dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
          file="$gtk_dir/settings.ini"
          grep -q "^gtk-cursor-theme-name=$cursor\$" "$file" 2>/dev/null || return 1
          case "$gtk_dir" in
            *gtk-3.0)
              grep -q "^gtk-theme-name=$gtk\$" "$file" 2>/dev/null || return 1
              if [ "$mode" = dark ]; then
                grep -q '^gtk-application-prefer-dark-theme=true$' "$file" 2>/dev/null || return 1
              else
                grep -q '^gtk-application-prefer-dark-theme=false$' "$file" 2>/dev/null || return 1
              fi
              ;;
            *gtk-4.0)
              grep -q "^gtk-interface-color-scheme=$mode\$" "$file" 2>/dev/null || return 1
              ;;
          esac
        done
        # HM 激活/清理可能把 dconf 恢复成默认；只有 dconf 可用时才校验。
        if dconf_ready; then
          [ "$(dconf read /org/gnome/desktop/interface/color-scheme)" = "'prefer-$mode'" ] || return 1
          [ "$(dconf read /org/gnome/desktop/interface/gtk-theme)" = "'$gtk'" ] || return 1
        fi
      }

      apply_mode() {
        mode="$1"
        cursor="$(cursor_name "$mode")" || return 1
        gtk="$(gtk_name "$mode")" || return 1
        mkdir -p "$niri_dir"
        write_niri "$cursor"
        write_gtk "$mode"
        dconf write /org/gnome/desktop/interface/cursor-theme "'$cursor'" >/dev/null 2>&1 || true
        dconf write /org/gnome/desktop/interface/cursor-size "$size" >/dev/null 2>&1 || true
        dconf write /org/gnome/desktop/interface/gtk-theme "'$gtk'" >/dev/null 2>&1 || true
        dconf write /org/gnome/desktop/interface/color-scheme "'prefer-$mode'" >/dev/null 2>&1 || true
        # 让之后由 systemd / D-Bus 激活的进程也拿到新主题；已在运行的外壳
        # （noctalia）仍保留旧环境，所以主要靠上面的 niri/GTK 两条路径。
        systemctl --user set-environment "XCURSOR_THEME=$cursor" >/dev/null 2>&1 || true
        dbus-update-activation-environment XCURSOR_THEME >/dev/null 2>&1 || true
        printf 'cursor-theme-sync: %s -> cursor=%s gtk=%s\n' "$mode" "$cursor" "$gtk"
      }

      # noctalia 的 IPC socket 跟着 WAYLAND_DISPLAY 走；服务可能在
      # niri-session 导入环境之前启动，这里从 runtime dir 反推。
      detect_mode() {
        if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
          for sock in "''${XDG_RUNTIME_DIR:-/run/user/$UID}"/noctalia-wayland-*.sock; do
            [ -e "$sock" ] || continue
            display="$sock"
            display="''${display##*/noctalia-}"
            WAYLAND_DISPLAY="''${display%.sock}"
            export WAYLAND_DISPLAY
            break
          done
        fi
        "$noctalia" msg theme-mode-get 2>/dev/null || true
      }

      if [ "$#" -gt 0 ]; then
        case "$1" in
          --apply)
            mode="$(detect_mode | tr -d '[:space:]')"
            case "$mode" in
              dark|light) apply_mode "$mode" ;;
            esac
            exit 0
            ;;
          --mode)
            if [ "$#" -ne 2 ]; then
              printf 'usage: %s [--apply|--mode dark|light]\n' "$0" >&2
              exit 2
            fi
            apply_mode "$2"
            exit $?
            ;;
          *)
            printf 'usage: %s [--apply|--mode dark|light]\n' "$0" >&2
            exit 2
            ;;
        esac
      fi

      last=""
      while :; do
        mode="$(detect_mode | tr -d '[:space:]')"
        case "$mode" in
          dark|light)
            if [ "$mode" != "$last" ] || ! applied "$mode"; then
              if apply_mode "$mode"; then
                last="$mode"
              fi
            fi
            ;;
        esac
        sleep 2
      done
    '';
  };
in
{
  # 光标与 GTK 深浅色的静态兜底：home-manager 由此派生 GTK 光标
  # （gtk.enable）并导出 XCURSOR_THEME/-SIZE；两套光标主题都随 package 进
  # profile。GTK 主题名/偏好由 home/gtk.nix 写成浅色基础值，运行时由
  # cursor-theme-sync 按 noctalia 模式接管。
  home.pointerCursor = {
    enable = true;
    name = theme.cursor-name-dark;
    package = cursorPackage;
    size = theme.cursor-size;
    gtk.enable = true;
  };

  systemd.user.services.cursor-theme-sync = {
    Unit = {
      Description = "Sync Xcursor and GTK color scheme with Noctalia dark/light mode";
      Documentation = [ "https://docs.noctalia.dev/v5/" ];
    };
    Service = {
      ExecStart = "${cursorSync}/bin/cursor-theme-sync";
      Restart = "always";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
