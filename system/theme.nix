# 全局主题：颜色与字号的唯一来源。
#
# 调色板：Nix Periwinkle —— 蓝灰夜色底 + NixOS logo 的紫蓝主强调。
# 背景/表面族色值取自壁纸（wallhaven-x6x3gz，深蓝底 + 几何雪花）的浅色块：
#   基底 #1E2030 → 雪花亮带 #2E3246 → 轮廓高光 #393D52
# 强调色取自官方 logo 渐变（nixos-artwork logo/nixos.svg）：
#   深蓝 #415E9A → #4A6BAF → #5277C3
#   亮蓝 #699AD7 → #7EB1DD → #7EBAE4
#   紫蓝 #637DDF → #649AFA → #719EFA
# 个别色做了明度/饱和度微调以适配深底。字号/字体仍是自己的。
# 接入情况：
#   - btop / fastfetch / zathura / gtk / fzf / bat / fuzzel / 光标：自动引用本文件
#   - ghostty：home/ghostty.nix 把本文件渲染成自定义主题 Nix-Periwinkle
#   - niri 的 config.kdl 是手写文件，暂无法插值，色值需与本文件手动保持一致
{
  # --- 字体 ---
  font = "FiraCode Nerd Font";
  font-size = 12;     # 终端字号
  font-size-ui = 11;  # GTK 界面字号
  font-size-bar = 12; # fuzzel / zathura 等小界面字号

  # --- 光标 ---
  # Bibata 按本主题重着色（深色填充 + 紫蓝描边），见 home/cursor-theme.nix
  cursor-name = "Bibata-Modern-DK";
  cursor-size = 24;

  # --- 语义色（Nix Periwinkle）---
  bg = "#2E3246";        # 主背景；壁纸浅色块（雪花亮带）；niri backdrop 兜底 / zathura / btop
  bg-alt = "#393D52";    # 凸起表面（选中项 / 侧栏）；壁纸轮廓高光色
  fg = "#D4DCEC";        # 主前景
  fg-bright = "#E6ECF8"; # 强调前景
  muted = "#9AA7C4";     # 次要可读文本
  muted-alt = "#737E9C"; # 装饰/禁用文本（随底色提亮，保持原可读档位）
  accent = "#649AFA";    # 主强调（logo 紫蓝渐变中段）：窗口边框、聚焦、niri insert-hint
  accent-2 = "#8B93F8";  # 交互强调（紫蓝再提亮）：菜单高亮、fzf 提示、zathura 搜索
  accent-bright = "#9DC4FD";        # 更亮的蓝，稀疏高亮
  accent-yellow-bright = "#C3CBFF"; # 强调文本的亮蓝紫（键名沿用旧结构）
  accent-deep = "#415E9A";          # logo 深蓝渐变起点：图表起点等深色装饰
  accent-bg = "#414868";            # 选区背景（ghostty selection）；壁纸最亮块再提亮一档
  cursor = "#DDE4F3";               # 光标颜色（ghostty cursor-color）
  black = "#1E2030";     # 最深表面；亮色强调上的文字；壁纸基底色
  border = "#4A506B";    # 非活动窗口边框（随底色提亮）
  urgent = "#D9827B";    # 紧急/警告

  # --- ANSI 16 色（Nix Periwinkle 终端色；蓝/青直接取 logo 渐变）---
  # normal (0-7)
  ansi = {
    black = "#393D52";
    red = "#CC8388";
    green = "#8BC49B";
    yellow = "#D5BC80";
    blue = "#649AFA";
    magenta = "#9D8FE0";
    cyan = "#7EB1DD";
    white = "#D4DCEC";
  };
  # bright (8-15)
  ansi-bright = {
    black = "#646C90";
    red = "#DDA1A0";
    green = "#A9D4B3";
    yellow = "#EBD3A2";
    blue = "#9DC4FD";
    magenta = "#BEAEEF";
    cyan = "#A5D1EC";
    white = "#E6ECF8";
  };
}
