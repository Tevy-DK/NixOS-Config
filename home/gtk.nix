# --- gtk ---
# 借鉴 koru：让 GTK 应用与桌面同一套视觉 —— 深底、方角、2px 强调色描边，
# 配色全部来自全局 theme.nix。
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

  # 方角 + 2px 强调色描边，与 niri 的窗口边框一致
  extras = ''
    window,
    window.background,
    headerbar,
    .titlebar,
    popover,
    popover.background,
    menu,
    tooltip,
    dialog,
    messagedialog,
    decoration {
      border-radius: 0;
    }

    /* GTK3 CSD outline */
    decoration {
      border: 2px solid ${theme.accent};
      box-shadow: none;
    }

    /* GTK4/libadwaita CSD outline */
    window.csd {
      border: 2px solid ${theme.accent};
      border-radius: 0;
      box-shadow: none;
    }
  '';
in
{
  gtk = {
    enable = true;
    colorScheme = "dark";

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    font = {
      name = theme.font;
      size = theme.font-size-ui;
    };

    # 图标主题沿用你原来的 Tela
    iconTheme = {
      name = "Tela";
      package = pkgs.tela-icon-theme;
    };

    gtk3.extraCss = colors + legacy + extras;
    gtk4.extraCss = colors + extras;

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
