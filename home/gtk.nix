# --- gtk ---
# GTK 配色/主题名交给 Noctalia 的 gtk3/gtk4 内置模板：
#   - 模板生成 ~/.config/gtk-{3,4}.0/noctalia.css，并把 @import 加进 gtk.css
#   - apply.sh 按模式用 gsettings/dconf 选 adw-gtk3 / adw-gtk3-dark
#   - [theme].sync_color_scheme 负责 org.gnome.desktop.interface.color-scheme
# Home Manager 只保留字体、图标、光标和 settings.ini 结构：
#   - gtk.theme = null：不再往 settings.ini/dconf 写固定 gtk-theme-name，
#     否则每次 HM 激活都会把 Noctalia 当前的深浅主题覆盖回固定值。
#     Noctalia 模板只写 dconf/GSettings；X11/XWayland 的 GTK 应用读
#     settings.ini，由 lib/gtk-theme-sync.nix 按模式补 gtk-theme-name。
#   - gtk.colorScheme = null：不写 prefer-dark / color-scheme。
#   - home.pointerCursor.gtk.enable = true（见 home/cursor-theme.nix）：
#     光标固定 Bibata Modern Ice，HM 直接写 settings.ini 和 dconf 的 cursor 键。
# adw-gtk3 仍显式安装：Noctalia 的 gtk apply.sh 靠它找 adw-gtk3 / dark 变体。
#
# nautilus 的玻璃完全由 niri 的窗口规则提供（与本项目作者 Fedora 机器上
# DMS 的配置同款）：background-effect 模糊 + opacity 0.75 +
# draw-border-with-background false。最后一项是关键——niri 的 border 默认
# 会在窗口背后整面涂边框色（聚焦蓝/失焦灰），不关掉任何透明都透不出模糊
# （2026-10-11 实锤，见 config.kdl 的 nautilus 规则注释）。
# 历史：@define-color 带 alpha 的 rgba 在 GTK4 4.22 上是坏的（0.7 档静默
# 失效回退不透明；alpha 0 的命名色会把 accent_bg 漏成整窗底色），透明 CSS
# 这条路彻底废弃，勿回退。
{
  pkgs,
  lib,
  theme,
  ...
}:
let
  gtkThemeSync = import ../lib/gtk-theme-sync.nix { inherit pkgs; };
in
{
  # GTK 外观基础值统一 mkDefault：homeConfigurations.all 全模块求值时会与其他
  # 模块同开，theme/iconTheme 的 package 是 unique 类型，同名值也要分优先级
  gtk = {
    enable = true;

    # 主题名由 Noctalia 模板按模式选（adw-gtk3 / adw-gtk3-dark），HM 不写。
    theme = lib.mkDefault null;

    # 必须是 null：写 "dark"/"light" 时 HM 每次激活都会向 settings.ini 写
    # gtk-application-prefer-dark-theme、向 dconf 写 color-scheme，把 Noctalia
    # 当前的模式重置掉。模式由 Noctalia 的 sync_color_scheme 维护。
    colorScheme = lib.mkDefault null;

    font = lib.mkDefault {
      name = theme.font;
      size = theme.font-size-ui;
    };

    iconTheme = lib.mkDefault {
      name = "Tela";
      package = pkgs.tela-icon-theme;
    };

    # X11/XWayland 的 GTK 应用读取 settings.ini 的 gtk-im-module；Wayland
    # 下 GTK 优先 text-input-v3，不受这几项影响。不要改成 GTK_IM_MODULE
    # 环境变量：它会泄漏进 Flatpak 沙箱，而沙箱里没有 fcitx GTK 模块。
    gtk2.extraConfig = ''gtk-im-module="fcitx"'';
    gtk3.extraConfig.gtk-im-module = "fcitx";
    gtk4.extraConfig.gtk-im-module = "fcitx";
  };

  # gtk.theme = null 后 HM 不再自动安装 adw-gtk3；Noctalia 的 apply.sh 需要它
  # 在 XDG_DATA_DIRS 里找主题目录，所以显式装一份。
  home.packages = [ pkgs.adw-gtk3 gtkThemeSync ];

  # gtk-theme-sync 会把这两个文件从 store 软链落成本地可写文件，只补
  # gtk-theme-name。HM 激活默认拒绝覆盖非软链文件，会报 "would be clobbered"
  # 并让 home-manager-<user>.service 整体失败；声明 force 后每次 switch 都
  # 还原软链，再由下面的激活钩子/Noctalia hook 补回当前模式的主题名。
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

  # HM 激活把 settings.ini 还原成 store 软链后 gtk-theme-name 会丢；用当前
  # Noctalia 模式补一次。Noctalia 没在跑时只告警，started hook 会再同步。
  home.activation.gtkThemeSyncApply = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
    # nixos-rebuild 的用户服务环境不保证带 WAYLAND_DISPLAY；Noctalia IPC
    # 靠它找 socket。先从 systemd 用户管理器环境补，不自己扫描 socket。
    if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
      WAYLAND_DISPLAY="$(${lib.getExe' pkgs.systemd "systemctl"} --user show-environment 2>/dev/null | ${lib.getExe' pkgs.gnused "sed"} -n 's/^WAYLAND_DISPLAY=//p')"
      export WAYLAND_DISPLAY
    fi
    if ! ${lib.getExe gtkThemeSync} --apply; then
      echo "gtk-theme-sync: Noctalia IPC unavailable; GTK theme will resync on next start or theme change" >&2
    fi
  '';

  # GTK3 "另存为" 对话框（xdg-desktop-portal-gtk）把窗口尺寸存在 dconf 里
  dconf.enable = true;
  dconf.settings."org/gtk/settings/file-chooser".window-size = lib.hm.gvariant.mkTuple [
    1231
    720
  ];
}
