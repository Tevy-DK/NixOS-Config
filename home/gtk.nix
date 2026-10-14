# --- gtk ---
# GTK 不做任何配色、也不做任何透明 CSS：外观即 libadwaita / adw-gtk3 的
# 默认值（深色偏好）。字体/图标/主题名保留。
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
    colorScheme = lib.mkDefault "dark";

    theme = lib.mkDefault {
      name = "adw-gtk3-dark";
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

    # GTK4 原生暗色（enum 的 nick 写法，libadwaita 才不告警）
    gtk4.colorScheme = null;
    gtk4.extraConfig."gtk-interface-color-scheme" = "dark";
  };

  # GTK3 "另存为" 对话框（xdg-desktop-portal-gtk）把窗口尺寸存在 dconf 里
  dconf.enable = true;
  dconf.settings."org/gtk/settings/file-chooser".window-size = lib.hm.gvariant.mkTuple [
    1231
    720
  ];
}
