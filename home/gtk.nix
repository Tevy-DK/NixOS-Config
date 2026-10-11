# --- gtk ---
# 颜色不写死、玻璃走 widget 级规则（2026-10-11 定稿，探针 + 嵌套 niri 实测）。
#
# 配色归属：noctalia 的内置 GTK 模板（theme.templates.enable_builtin_templates
# 默认 true）从当前壁纸算 M3 调色板写 ~/.config/gtk-{3,4}.0/noctalia.css。
# gtk.css 顶部预置 @import url("noctalia.css")：GTK 按序加载、跨文件命名色
# 可解析，而 noctalia 的 apply.sh 幂等检查「内容含 noctalia.css + @import 即
# 跳过改写」从此不再动 HM 的文件——双向停火，rebuild 也不会再有覆盖提示。
# （教训：此前三套写死方案——koru 方角描边、theme.nix 命名色覆盖、glass
# alpha 底色——全和这个每壁纸事件都会改写 gtk.css 的钩子结构性打架。）
#
# 玻璃：niri 的 background-effect 只透过窗口自绘的半透明像素生效，而
# @define-color 带 alpha 的 rgba 在 GTK4 4.22 上是坏的（0.7 档静默失效回退
# 不透明；alpha 0 的命名色会把 accent_bg 漏成整窗底色）。所以透明写进
# widget 级规则：window 一层 alpha(@window_bg_color, 0.7)——色值引用命名色
# （noctalia 调色板，随壁纸走），这里不写死任何颜色；headerbar/侧栏/视图/
# 卡片全透，只留 window 一层保全窗透明度均匀；弹层（popover/dialog）保持
# noctalia 的不透明色保可读性。niri 侧模糊由 config.kdl 的 nautilus
# window-rule 执行，不叠 opacity 免得双重变暗。GTK3 不带玻璃（adw-gtk3
# 透明表现不稳），只挂 import 让 noctalia 管色。
{
  pkgs,
  lib,
  theme,
  ...
}:
let
  # apply.sh 的幂等检查认「内容含 noctalia.css 且含 @import」；
  # @import 必须位于文件最前，extraCss 会原样成为 gtk.css 全文
  noctaliaImport = ''@import url("noctalia.css");'';

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

    gtk3.extraCss = noctaliaImport;
    gtk4.extraCss = noctaliaImport + "\n\n" + glass;

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
