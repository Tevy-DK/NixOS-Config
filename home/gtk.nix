# --- gtk ---
# GTK 不做任何配色、也不做任何透明 CSS：外观即 libadwaita / adw-gtk3 的
# 默认值。字体/图标/基础主题名保留；深/浅色由 noctalia 决定，运行期由
# home/cursor-theme.nix 的 cursor-theme-sync 写进 settings.ini 与 dconf。
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
{
  # GTK 外观基础值统一 mkDefault：homeConfigurations.all 全模块求值时会与其他
  # 模块同开，theme/iconTheme 的 package 是 unique 类型，同名值也要分优先级
  gtk = {
    enable = true;

    # 必须是 null：写 "dark" 时 HM 每次激活都会向 settings.ini 写
    # gtk-application-prefer-dark-theme、向 dconf 写 color-scheme=prefer-dark，
    # 把 noctalia 当前的浅色重置掉。模式由 cursor-theme-sync 在运行期写入。
    colorScheme = lib.mkDefault null;

    # 浅色基础主题（静态兜底）；深色变体由 cursor-theme-sync 切换。
    theme = lib.mkDefault {
      name = theme.gtk-theme;
      package = pkgs.adw-gtk3;
    };

    font = lib.mkDefault {
      name = theme.font;
      size = theme.font-size-ui;
    };

    iconTheme = lib.mkDefault {
      name = "Tela";
      package = pkgs.tela-icon-theme;
    };

    # GTK4 的 gtk-interface-color-scheme 同样交给 cursor-theme-sync 按模式写；
    # 这里不要写死 "dark"（stateVersion 26.05 起 gtk4.theme 默认也是 null）。
  };

  # cursor-theme-sync 会把这两个文件从 store 软链落成本地可写文件，并在
  # noctalia 模式变化或 HM 激活还原软链后写回 cursor 与 GTK 深浅色键
  # （home/cursor-theme.nix）。HM 激活默认拒绝覆盖非软链文件，会报
  # "would be clobbered" 并让 home-manager-<user>.service 整体失败；
  # 声明 force 后每次 switch 都还原软链，服务 2s 内再把当前模式的键写回去。
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

  # GTK3 "另存为" 对话框（xdg-desktop-portal-gtk）把窗口尺寸存在 dconf 里
  dconf.enable = true;
  dconf.settings."org/gtk/settings/file-chooser".window-size = lib.hm.gvariant.mkTuple [
    1231
    720
  ];
}
