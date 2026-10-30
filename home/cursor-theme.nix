# --- cursor ---
# Bibata Modern 两套重着色（lib/cursor-package.nix）：
#   dark  = 黑体白边   light = 白体黑边
# 与 config.kdl 的兜底 cursor 块同为 dark；GTK 侧基础包由 home.pointerCursor
# 安装，实际光标名/尺寸由 cursor-theme-sync 跟随 Noctalia 模式写入。
#
# 事件驱动（无轮询、无常驻服务）：
#   Noctalia started            → cursor-theme-sync --apply
#   Noctalia theme_mode_changed → cursor-theme-sync --mode "$NOCTALIA_THEME_MODE"
#   Home Manager 激活            → cursor-theme-sync --apply（补回被还原的 settings.ini）
# Hook 在 home/noctalia.nix 里用 lib.getExe 注入 Store 路径，不依赖 PATH。
#
# 脚本只负责光标相关设置：
#   1. ~/.config/niri/cursor.kdl —— niri 的 include 监听该文件，重载后
#      合成器和它拉起的客户端都换用新主题（niri 自己会设置 XCURSOR_THEME）
#   2. ~/.config/gtk-{3,4}.0/settings.ini —— 只写 gtk-cursor-theme-name /
#      gtk-cursor-theme-size；GTK 主题名、prefer-dark、color-scheme 归 Noctalia
#   3. dconf —— 只写 cursor-theme / cursor-size
{ pkgs, lib, theme, ... }:
let
  cursorPackage = import ../lib/cursor-package.nix { inherit pkgs theme; };
  cursorSync = import ../lib/cursor-theme-sync.nix { inherit pkgs theme; };
in
{
  # 光标包与静态兜底：home-manager 由此安装两套 Bibata 并导出
  # XCURSOR_THEME/-SIZE（dark）。gtk.enable = false 是关键：开启时 HM 每次
  # 激活都会把固定 dark 光标名/尺寸写进 settings.ini 和 dconf，覆盖运行期
  # Noctalia hook 的结果；关掉后 HM 只负责安装包和环境变量，光标键由脚本
  # 在运行时（以及每次 HM 激活后）写入。
  home.pointerCursor = {
    enable = true;
    name = theme.cursor-name-dark;
    package = cursorPackage;
    size = theme.cursor-size;
    gtk.enable = false;
  };

  # XCURSOR_THEME 固定指向稳定别名，而不是 dark/light 具体名字。
  # niri 每次 spawn 子进程都会读取自己的 environment 覆盖；systemd/Noctalia
  # 新拉起的进程也拿别名。模式切换只需由 cursor-theme-sync 重指
  # ~/.local/share/icons/Bibata-Modern-Current。已在运行的旧进程若仍持有
  # 具体的 Bibata-Modern-Dark/Light，需要重启一次才会改用别名。
  home.sessionVariables.XCURSOR_THEME = lib.mkForce theme.cursor-alias;

  # 提供给手动排查 / 测试；Noctalia hook 直接用同一个 Store 路径，不依赖 PATH。
  home.packages = [ cursorSync ];

  # HM 激活会把 settings.ini 还原成 store 软链（home/gtk.nix 里的 force），
  # 光标键因此消失。这里在 linkGeneration 和 dconfSettings 之后补回当前模式；
  # Noctalia 没在跑时只告警，不阻塞激活，下次 started hook 会再同步。
  home.activation.cursorThemeSyncApply = lib.hm.dag.entryAfter [ "linkGeneration" "dconfSettings" ] ''
    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
    # nixos-rebuild 的用户服务环境不保证带 WAYLAND_DISPLAY；Noctalia IPC
    # 靠它找 socket。先从 systemd 用户管理器环境补，不自己扫描 socket。
    if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
      WAYLAND_DISPLAY="$(${lib.getExe' pkgs.systemd "systemctl"} --user show-environment 2>/dev/null | ${lib.getExe' pkgs.gnused "sed"} -n 's/^WAYLAND_DISPLAY=//p')"
      export WAYLAND_DISPLAY
    fi
    if ! ${lib.getExe cursorSync} --apply; then
      echo "cursor-theme-sync: Noctalia IPC unavailable; cursor will resync on next Noctalia start or theme change" >&2
    fi
  '';
}
