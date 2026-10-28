# --- cursor ---
# Bibata Modern 两套重着色（lib/cursor-package.nix）：
#   dark  = 黑体白边   light = 白体黑边
# 与 config.kdl 的兜底 cursor 块同为 dark；GTK 侧由 home.pointerCursor 注入。
#
# 自动切换：cursor-theme-sync.service 轮询 noctalia 的解析后主题模式
# （noctalia msg theme-mode-get），变化时同时更新：
#   1. ~/.config/niri/cursor.kdl —— niri 的 include 监听该文件，重载后
#      合成器和它拉起的客户端都换用新主题（niri 自己会设置 XCURSOR_THEME）
#   2. ~/.config/gtk-{3,4}.0/settings.ini 与 dconf —— 新开的 GTK 应用立即用新主题
# 正在运行的 GTK 应用会缓存已加载的光标，切换后可能保持旧样式直到重启；
# 合成器光标（桌面/窗口边缘）是即时的。
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
      # 之后只改 cursor 这一行；下次 HM 激活还原软链后，主循环会再纠正。
      write_gtk() {
        name="$1"
        for dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
          file="$dir/settings.ini"
          mkdir -p "$dir"
          if [ -L "$file" ]; then
            target="$(readlink -f "$file")"
            cp --remove-destination "$target" "$file"
          fi
          if [ ! -e "$file" ]; then
            printf '%s\n' '[Settings]' > "$file"
          fi
          # store 里的 settings.ini 是 0444，落成本地文件后要允许追加/改写
          chmod u+w "$file"
          if grep -q '^gtk-cursor-theme-name=' "$file"; then
            sed -i "s|^gtk-cursor-theme-name=.*|gtk-cursor-theme-name=$name|" "$file"
          else
            printf 'gtk-cursor-theme-name=%s\n' "$name" >> "$file"
          fi
        done
      }

      applied() {
        name="$1"
        grep -q "xcursor-theme \"$name\"" "$niri_file" 2>/dev/null || return 1
        for dir in "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"; do
          grep -q "^gtk-cursor-theme-name=$name\$" "$dir/settings.ini" 2>/dev/null || return 1
        done
      }

      apply_mode() {
        mode="$1"
        name="$(cursor_name "$mode")" || return 1
        mkdir -p "$niri_dir"
        write_niri "$name"
        write_gtk "$name"
        dconf write /org/gnome/desktop/interface/cursor-theme "'$name'" >/dev/null 2>&1 || true
        dconf write /org/gnome/desktop/interface/cursor-size "$size" >/dev/null 2>&1 || true
        # 让之后由 systemd / D-Bus 激活的进程也拿到新主题；已在运行的外壳
        # （noctalia）仍保留旧环境，所以主要靠上面的 niri/GTK 两条路径。
        systemctl --user set-environment "XCURSOR_THEME=$name" >/dev/null 2>&1 || true
        dbus-update-activation-environment XCURSOR_THEME >/dev/null 2>&1 || true
        printf 'cursor-theme-sync: %s -> %s\n' "$mode" "$name"
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
            name="$(cursor_name "$mode")"
            if [ "$mode" != "$last" ] || ! applied "$name"; then
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
  # 会话里唯一的光标定义：home-manager 由此派生 GTK 光标（gtk.enable）并导出
  # XCURSOR_THEME/-SIZE；两套主题都随 package 进 profile，服务按模式挑选。
  # 这里的 name 只是启动兜底（dark），运行时由 cursor-theme-sync 接管。
  home.pointerCursor = {
    enable = true;
    name = theme.cursor-name-dark;
    package = cursorPackage;
    size = theme.cursor-size;
    gtk.enable = true;
  };

  systemd.user.services.cursor-theme-sync = {
    Unit = {
      Description = "Sync Xcursor theme with Noctalia dark/light mode";
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
