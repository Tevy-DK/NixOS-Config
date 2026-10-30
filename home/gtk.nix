# --- gtk ---
# GTK 配色/主题名交给 Noctalia 的 gtk3/gtk4 内置模板：
#   - 模板生成 ~/.config/gtk-{3,4}.0/noctalia.css，并把 @import 加进 gtk.css
#   - apply.sh 按模式用 gsettings/dconf 选 adw-gtk3 / adw-gtk3-dark
#   - [theme].sync_color_scheme 负责 org.gnome.desktop.interface.color-scheme
# Home Manager 只保留字体、图标、光标包和 settings.ini 结构：
#   - gtk.theme = null：不再往 settings.ini/dconf 写固定 gtk-theme-name，
#     否则每次 HM 激活都会把 Noctalia 当前的深浅主题覆盖回浅色。
#   - gtk.colorScheme = null：不写 prefer-dark / color-scheme。
#   - home.pointerCursor.gtk.enable = false（见 home/cursor-theme.nix）：
#     光标名/尺寸由 cursor-theme-sync 按 Noctalia 模式写入，HM 不抢同一个键。
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
  };

  # gtk.theme = null 后 HM 不再自动安装 adw-gtk3；Noctalia 的 apply.sh 需要它
  # 在 XDG_DATA_DIRS 里找主题目录，所以显式装一份。
  home.packages = [ pkgs.adw-gtk3 ];

  # cursor-theme-sync 会把这两个文件从 store 软链落成本地可写文件，并只补
  # gtk-cursor-theme-name / gtk-cursor-theme-size。HM 激活默认拒绝覆盖非软链
  # 文件，会报 "would be clobbered" 并让 home-manager-<user>.service 整体失败；
  # 声明 force 后每次 switch 都还原软链，再由 cursor-theme-sync 的激活钩子
  # 把当前模式的 cursor 键写回去（见 home/cursor-theme.nix）。
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

  # GTK3 "另存为" 对话框（xdg-desktop-portal-gtk）把窗口尺寸存在 dconf 里
  dconf.enable = true;
  dconf.settings."org/gtk/settings/file-chooser".window-size = lib.hm.gvariant.mkTuple [
    1231
    720
  ];
}
