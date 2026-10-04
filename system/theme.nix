# 全局主题（借鉴 koru 的 theme.nix）：颜色与字号的唯一来源。
#
# 调色板：Koru Fern —— 低刺激的绿炭深底 + 蕨绿主强调 + 嫩黄交互强调，
# 色值完全取自 koru 的 system/theme.nix（2025-10 下载版）。字号/字体仍是自己的。
# 接入情况：
#   - btop / fastfetch / zathura / gtk / fzf / bat / fuzzel / 光标：自动引用本文件
#   - ghostty：home/ghostty.nix 把本文件渲染成自定义主题 Koru-Fern
#   - niri 的 config.kdl 是手写文件，暂无法插值，色值需与本文件手动保持一致
{
  # --- 字体 ---
  font = "FiraCode Nerd Font";
  font-size = 12;     # 终端字号
  font-size-ui = 11;  # GTK 界面字号
  font-size-bar = 12; # fuzzel / zathura 等小界面字号

  # --- 光标 ---
  # Bibata 按本主题重着色（深色填充 + 蕨绿描边），见 home/cursor-theme.nix
  cursor-name = "Bibata-Modern-DK";
  cursor-size = 24;

  # --- 语义色（Koru Fern）---
  bg = "#171E1A";        # 主背景；niri 桌面底 / zathura / btop
  bg-alt = "#222D26";    # 凸起表面（选中项 / 侧栏）
  fg = "#D2DCD0";        # 主前景
  fg-bright = "#E1E8DB"; # 强调前景
  muted = "#A5B3A2";     # 次要可读文本
  muted-alt = "#788A78"; # 装饰/禁用文本
  accent = "#8FBF88";    # 主强调（蕨绿）：窗口边框、聚焦、niri insert-hint
  accent-2 = "#E6D87A";  # 交互强调（嫩黄，koru 的 accent-yellow）：菜单高亮、fzf 提示、zathura 搜索
  accent-bright = "#B4D6A2";     # 更亮的蕨绿，稀疏高亮
  accent-yellow-bright = "#F5E9A6"; # 强调文本的亮黄
  accent-deep = "#527B59";       # 图表起点等深色装饰
  accent-bg = "#334936";         # 选区背景（ghostty selection）
  cursor = "#DEE7D5";            # 光标颜色（ghostty cursor-color）
  black = "#121813";     # 最深表面；亮色强调上的文字
  border = "#425347";    # 非活动窗口边框
  urgent = "#D39B79";    # 紧急/警告

  # --- ANSI 16 色（Koru Fern 终端色）---
  # normal (0-7)
  ansi = {
    black = "#222D26";
    red = "#CC8F88";
    green = "#8FBF88";
    yellow = "#E6D87A";
    blue = "#8EAAB8";
    magenta = "#B39BB5";
    cyan = "#88B8AB";
    white = "#D2DCD0";
  };
  # bright (8-15)
  ansi-bright = {
    black = "#526457";
    red = "#DDA39A";
    green = "#B4D6A2";
    yellow = "#F5E9A6";
    blue = "#ACC3CE";
    magenta = "#CAB5CA";
    cyan = "#A6D0C2";
    white = "#E1E8DB";
  };
}
