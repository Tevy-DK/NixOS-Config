# --- gtk ---
# 配色唯一来源是全局 theme.nix；几何（圆角/阴影/边框）交给 libadwaita 原生
# CSD + niri 的 layout.border。
#
# 玻璃（2026-10-11 探针+嵌套 niri 实测定稿的机制）：niri 的 background-effect
# 模糊只透过窗口自绘的半透明像素生效（不透明整面会完全盖住它；window-rule
# 的 opacity 压在最终合成上也救不了），而 @define-color 带 alpha 的 rgba 在
# GTK4 4.22 上是坏的（0.7 档静默失效回退不透明；alpha 0 的命名色会把
# accent_bg 漏成整窗底色）。所以命名色全部不透明，透明写在 widget 级规则里：
# window 一层 alpha(@window_bg_color, 0.7)，headerbar/侧栏/视图/卡片全透只留
# 一层保全窗透明度均匀；弹层（popover/dialog）保持不透明色保可读性。文字/
# 图标照常实心绘制，不受透明影响。niri 侧模糊在 config.kdl 的 nautilus
# window-rule（不叠 opacity 免得双重变暗）。GTK3 不带玻璃（adw-gtk3 透明
# 表现不稳）。
#
# 历史：noctalia 的内置 GTK 模板曾在每次壁纸/主题事件改写 gtk.css（见
# noctalia.nix，已停用），与其拔河导致 HM 反复提示覆盖、glass 部署三次失败，
# 最终定为 theme.nix 固定调色板 + widget 级透明——flake 声明一切、完全可复现。
{
  pkgs,
  lib,
  theme,
  ...
}:
let
  # libadwaita 命名色，GTK3（adw-gtk3）与 GTK4 共用；全部不透明，
  # 透明度一律走下方 glass 的 widget 级规则，勿写进 @define-color
  colors = ''
    @define-color accent_color ${theme.accent};
    @define-color accent_bg_color ${theme.accent};
    @define-color accent_fg_color ${theme.black};
    @define-color window_bg_color ${theme.bg};
    @define-color window_fg_color ${theme.fg};
    @define-color view_bg_color ${theme.bg};
    @define-color view_fg_color ${theme.fg};
    @define-color headerbar_bg_color ${theme.bg};
    @define-color headerbar_fg_color ${theme.fg};
    @define-color sidebar_bg_color ${theme.bg-alt};
    @define-color sidebar_fg_color ${theme.fg};
    @define-color card_bg_color ${theme.bg-alt};
    @define-color card_fg_color ${theme.fg};
    @define-color dialog_bg_color ${theme.bg};
    @define-color dialog_fg_color ${theme.fg};
    @define-color popover_bg_color ${theme.bg-alt};
    @define-color popover_fg_color ${theme.fg};
    @define-color borders ${theme.border};
  '';

  # 前 libadwaita 时代的 GTK3 名字（少量组件还在用）
  legacy = ''
    @define-color theme_bg_color ${theme.bg};
    @define-color theme_fg_color ${theme.fg};
    @define-color theme_base_color ${theme.bg};
    @define-color theme_text_color ${theme.fg};
    @define-color theme_selected_bg_color ${theme.accent};
    @define-color theme_selected_fg_color ${theme.black};
    @define-color theme_unfocused_bg_color ${theme.bg};
    @define-color theme_unfocused_fg_color ${theme.muted};
  '';

  # GTK4 玻璃层：只留 window 一层 alpha，内层（headerbar/侧栏/视图/卡片）
  # 全透，全窗透明度均匀；底色引用 theme.bg（蓝灰夜色，源自壁纸浅色块）
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

    gtk3.extraCss = colors + legacy;
    gtk4.extraCss = colors + glass;

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
