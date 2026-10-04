# --- zathura ---
# 键盘驱动的 PDF 阅读器（vim 式按键，零装饰），配色来自全局主题（借鉴 koru）。
# Refs: https://man.archlinux.org/man/zathurarc.5
{ theme, ... }:
{
  programs.zathura = {
    enable = true;
    options = {
      font = "${theme.font} ${toString theme.font-size-bar}";
      default-bg = theme.bg;
      default-fg = theme.fg;
      statusbar-bg = theme.bg-alt;
      statusbar-fg = theme.fg;
      inputbar-bg = theme.bg;
      inputbar-fg = theme.fg-bright;
      completion-bg = theme.bg-alt;
      completion-fg = theme.fg;
      completion-highlight-bg = theme.accent-2;
      completion-highlight-fg = theme.black;
      highlight-color = theme.accent-2;
      highlight-active-color = theme.accent-bright;
      # 选中即进系统剪贴板（Wayland）
      selection-clipboard = "clipboard";
      adjust-open = "best-fit";
      scroll-step = 60;
    };
  };
}
