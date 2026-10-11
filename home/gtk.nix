# --- gtk ---
# GTK 的颜色不在这里写死，完全交给 noctalia：它内置 gtk3/gtk4 主题模板
# （enableBuiltinTemplates 默认 true），从当前壁纸算 M3 调色板写
# ~/.config/gtk-{3,4}.0/noctalia.css，并在 apply.sh 钩子里改写 gtk.css 追加
# @import——每次壁纸/主题事件都会重写。这层曾经的三套写死方案（koru 方角
# 描边 → theme.nix 命名色覆盖 → glass alpha 底色）全部与它打架：
#   - HM 每次 rebuild 提示覆盖 gtk-3.0/gtk-4.0.css（noctalia 在背后改过，
#     甚至会把 HM 的只读软链删掉换成本地文件）；
#   - GTK4 4.22 实测 @define-color 不吃带 alpha 的 rgba（0.7 静默失效回退
#     不透明色；alpha 0 的命名色更会把 accent_bg 漏成整窗底色，换壁纸就
#     跟着 noctalia 调色板变色）。
# 所以这里只留与颜色无关的基础项：adw-gtk3（noctalia 的 apply.sh 也会把
# gtk-theme 设成 adw-gtk3-dark，正好一致）、字体、图标、深色偏好。
# 若日后要重做毛玻璃：别动 @define-color，用 widget 级规则
# （window.background { background-color: alpha(...) } + headerbar/侧栏
# transparent），嵌套 niri 探针实测这条路是通的。
{
  pkgs,
  lib,
  theme,
  ...
}:
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
