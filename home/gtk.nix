# --- gtk ---
# GTK 不做任何配色：颜色一律是 libadwaita / adw-gtk3 的默认值（深色偏好下
# window 默认 #222226 系）。字体/图标/主题名保留。
#
# 唯一的 CSS 是玻璃透明（透明不是配色）：niri 的 background-effect 模糊只
# 透过窗口自绘的半透明像素生效（不透明整面会完全盖住它；window-rule 的
# opacity 压在最终合成上也救不了），而 @define-color 带 alpha 的 rgba 在
# GTK4 4.22 上是坏的（0.7 档静默失效回退不透明；alpha 0 的命名色会把
# accent_bg 漏成整窗底色）。所以透明写在 widget 级规则里：window 一层
# alpha(@window_bg_color, 0.7)——@window_bg_color 是 adwaita 自己的默认命名
# 色（这里不覆盖它），headerbar/侧栏/视图/卡片全透只留一层保全窗透明度
# 均匀。文字/图标照常实心绘制。niri 侧模糊在 config.kdl 的 nautilus
# window-rule（不叠 opacity 免得双重变暗）。GTK3 不带玻璃（adw-gtk3 透明
# 表现不稳）。
#
# 注意：壁纸偏暗时 0.7 的透出很微妙，玻璃可能「看不出」——存在感不足就调
# 低 alpha（如 0.5）。勿把透明写进 @define-color（见上）。
{
  pkgs,
  lib,
  theme,
  ...
}:
let
  glass = ''
    window.background { background-color: alpha(@window_bg_color, 0.7); }
    headerbar { background-color: transparent; }
    .sidebar-pane, .navigation-sidebar, .secondary-sidebar { background-color: transparent; }
    .view { background-color: transparent; }
    .card { background-color: transparent; }
  '';
in
{
  # GTK 外观基础值统一 mkDefault：hyprland 档案里这些键由 caelestia.nix 显式
  # 声明（两侧值相同）；只有 homeConfigurations.all 全模块求值时会同开，
  # theme/iconTheme 的 package 是 unique 类型，同名值也要分优先级
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

    gtk4.extraCss = glass;

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
