# --- gtk ---
# 颜色不写死、玻璃独立成文件、HM 不碰 gtk.css（2026-10-11 终版，探针+嵌套
# niri 实测）。
#
# 配色归属：noctalia 的内置 GTK 模板（theme.templates.enable_builtin_templates
# 默认 true）在每次壁纸/主题事件写 ~/.config/gtk-{3,4}.0/noctalia.css（M3 壁纸
# 调色板），并用 apply.sh 改写 gtk.css（追加 @import；遇到 HM 只读软链会删链
# 换本地文件）。gtk.css 的所有权归它——HM 此前三次部署都在这个文件上和它
# 拔河（rebuild 反复提示覆盖），故 extraCss 全部撤除，HM 不再管 gtk.css。
#
# 玻璃：写在独立的 glass.css（没有任何人抢这个文件名，HM 独占、版本可控，
# 改透明度 rebuild 即可）。niri 的 background-effect 模糊只透过窗口自绘的
# 半透明像素生效，而 @define-color 带 alpha 的 rgba 在 GTK4 4.22 上是坏的
# （0.7 档静默失效回退不透明；alpha 0 命名色把 accent_bg 漏成整窗底色），
# 所以透明走 widget 级规则：window 一层 alpha(@window_bg_color, 0.7)（引用
# noctalia 调色板、随壁纸走），headerbar/侧栏/视图/卡片全透只留一层保均匀，
# 弹层保持 noctalia 的不透明色。色值 @window_bg_color 由 gtk.css 顶部的
# noctalia.css import 提供。niri 侧模糊在 config.kdl 的 nautilus window-rule。
#
# 机器上的一次性接线（noctalia 已创建 import-only 的 gtk.css 后执行一次）：
#   sed -i '/noctalia\.css/a @import url("glass.css");' ~/.config/gtk-4.0/gtk.css
# （@import 必须都在文件头部；此后 apply.sh 的幂等检查会跳过整个文件。）
# GTK3 不带玻璃（adw-gtk3 透明表现不稳），颜色靠 noctalia 自己管的 import。
{
  pkgs,
  lib,
  theme,
  ...
}:
let
  glass = ''
    /* 毛玻璃：底色引用 noctalia 调色板（gtk.css import 的 noctalia.css 提供），
       只留 window 一层 alpha；勿把透明写进 @define-color（GTK4 上静默失效/
       漏 accent，见文件头注释） */
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

    # GTK4 原生暗色（enum 的 nick 写法，libadwaita 才不告警）
    gtk4.colorScheme = null;
    gtk4.extraConfig."gtk-interface-color-scheme" = "dark";
  };

  # 玻璃规则独立文件：gtk.css 归 noctalia（它按壁纸事件重写），这个文件名
  # 无人争夺，HM 独占；机器侧一次性往 gtk.css 加 @import 接线（见文件头）
  xdg.configFile."gtk-4.0/glass.css".text = glass;

  # GTK3 "另存为" 对话框（xdg-desktop-portal-gtk）把窗口尺寸存在 dconf 里
  dconf.enable = true;
  dconf.settings."org/gtk/settings/file-chooser".window-size = lib.hm.gvariant.mkTuple [
    1231
    720
  ];
}
