# --- gtk ---
# 让 GTK 应用与桌面同一套视觉：配色全部来自全局 theme.nix；
# 几何（圆角/阴影/边框）交给 libadwaita 原生 CSD + niri 的 layout.border，
# 不再方角描边——那套 koru 方角样式让 GTK 窗口整窗画成不透明方板，
# 看起来像跑在 XWayland 里，与 noctalia 玻璃风冲突。
#
# GTK3: adw-gtk3-dark 读取 libadwaita 命名色（非老的 @theme_* 名），两者都覆盖。
# GTK4/libadwaita: 不认主题名，用原生 gtk-interface-color-scheme + 同套命名色。
{
  pkgs,
  lib,
  theme,
  ...
}:
let
  # libadwaita 命名色，GTK3（adw-gtk3）与 GTK4 共用
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

  # "#RRGGBB" → "R, G, B"，给 GTK4 的 rgba() 用（TOML 整数字面量支持 0x 前缀）
  rgbOf = hex:
    let
      h = builtins.substring 1 6 hex;
      chan = off: (builtins.fromTOML "v = 0x${builtins.substring off 2 h}").v;
    in
    "${toString (chan 0)}, ${toString (chan 2)}, ${toString (chan 4)}";

  # GTK4 玻璃层（嵌套 niri 实测通过）：libadwaita 默认整面画不透明底，niri 的
  # background-effect 模糊只透过窗口自绘的半透明像素生效（wiki Window-Effects：
  # 「整面不透明会完全盖住效果」，window-rule 的 opacity 压在最终合成上救不了
  # 模糊）。所以大面底色带 alpha 画进 surface；内层（headerbar/侧栏/视图/卡片）
  # 全透、只留 window 一层 alpha，全窗透明度均匀；弹层（popover/dialog）保持
  # colors 里的不透明值保可读性。GTK3 不带玻璃（adw-gtk3 透明表现不稳）。
  glass = ''
    @define-color window_bg_color rgba(${rgbOf theme.bg}, 0.7);
    @define-color headerbar_bg_color rgba(${rgbOf theme.bg}, 0);
    @define-color sidebar_bg_color rgba(${rgbOf theme.bg}, 0);
    @define-color view_bg_color rgba(${rgbOf theme.bg}, 0);
    @define-color card_bg_color rgba(${rgbOf theme.bg}, 0);
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
