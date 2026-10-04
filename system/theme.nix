# 全局主题（借鉴 koru 的 theme.nix）：颜色与字号的唯一来源。
#
# 调色板：紫蓝系 —— Catppuccin Mocha 深底 + 你的蓝 (#a4c9fe) 做主强调、
# Mocha 紫 (#cba6f7) 做交互强调（菜单/提示/fzf 焦点）。
# 接入情况：
#   - btop / fastfetch / zathura / gtk / fzf / bat / fuzzel / 光标：自动引用本文件
#   - niri 的 config.kdl 是手写文件，暂无法插值，色值需与本文件手动保持一致
{
  # --- 字体 ---
  font = "FiraCode Nerd Font";
  font-size = 12;     # 终端字号
  font-size-ui = 11;  # GTK 界面字号
  font-size-bar = 12; # fuzzel / zathura 等小界面字号

  # --- 光标 ---
  # Bibata 按本主题重着色（黑色填充 + 蓝色描边），见 home/cursor-theme.nix
  cursor-name = "Bibata-Modern-DK";
  cursor-size = 24;

  # --- 语义色 ---
  bg = "#1e1e2e";        # 主背景（Mocha base；niri 桌面底 / zathura / btop）
  bg-alt = "#313244";    # 凸起表面（Mocha surface0；选中项 / 侧栏）
  fg = "#cdd6f4";        # 主前景（Mocha text）
  fg-bright = "#e6e6f0"; # 强调前景
  muted = "#a6adc8";     # 次要可读文本（Mocha subtext0）
  muted-alt = "#6c7086"; # 装饰/禁用文本（Mocha overlay0）
  accent = "#a4c9fe";    # 主强调：窗口边框、聚焦、niri insert-hint
  accent-2 = "#cba6f7";  # 交互强调：菜单高亮、fzf 提示、zathura 搜索（Mocha mauve）
  accent-bright = "#cfe2ff";   # 更亮的蓝，稀疏高亮
  accent-deep = "#4a7099";     # 图表起点等深色装饰
  black = "#11111b";     # 最深表面（Mocha crust）；亮色强调上的文字
  border = "#8d9199";    # 非活动窗口边框
  urgent = "#ffb4ab";    # 紧急/警告

  # --- ANSI 16 色（Catppuccin Mocha 终端色）---
  # normal (0-7)
  ansi = {
    black = "#45475a";
    red = "#f38ba8";
    green = "#a6e3a1";
    yellow = "#f9e2af";
    blue = "#89b4fa";
    magenta = "#cba6f7";
    cyan = "#94e2d5";
    white = "#bac8ef";
  };
  # bright (8-15)
  ansi-bright = {
    black = "#585b70";
    red = "#f38ba8";
    green = "#a6e3a1";
    yellow = "#f9e2af";
    blue = "#89b4fa";
    magenta = "#cba6f7";
    cyan = "#94e2d5";
    white = "#a6adc8";
  };
}
