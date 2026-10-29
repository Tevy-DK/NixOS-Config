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
#   - btop / fastfetch / zathura / fzf / bat / fuzzel / 光标：自动引用本文件
#   - ghostty：home/ghostty.nix 渲染成 Nix-Periwinkle-Dark / -Light 成对主题，
#     浅色色板见文件末尾 terminal-light（仅终端 light 主题使用）
#   - GTK/Qt/niri 窗口配色：2026-10-17 起由 noctalia 内置模板自动生成
#     （跟壁纸取色，见 home/noctalia.nix 的 templates 注释），本文件不再参与
#   - niri 的 config.kdl：颜色节点已交给 noctalia 模板；仅 overview 的
#     backdrop 兜底色（= bg）是手写静态值
{
  # --- 字体 ---
  font = "FiraCode Nerd Font";
  font-size = 12;     # 终端字号
  font-size-ui = 11;  # GTK 界面字号
  font-size-bar = 12; # fuzzel / zathura 等小界面字号

  # --- 光标 ---
  # Bibata 两套重着色（见 lib/cursor-package.nix）：
  #   dark  = 黑体白边   light = 白体黑边
  # 桌面会话里由 home/cursor-theme.nix 的服务按 noctalia 深浅色自动切换；
  # 登录页没有运行时切换，固定用 dark。
  cursor-name-dark = "Bibata-Modern-Dark";
  cursor-name-light = "Bibata-Modern-Light";
  cursor-size = 24;

  # --- 语义色（Nix Periwinkle）---
  bg = "#2E3246";        # 主背景；壁纸浅色块（雪花亮带）；niri backdrop 兜底 / zathura / btop
  bg-alt = "#393D52";    # 凸起表面（选中项 / 侧栏）；壁纸轮廓高光色
  fg = "#D4DCEC";        # 主前景
  fg-bright = "#E6ECF8"; # 强调前景
  muted = "#9AA7C4";     # 次要可读文本
  muted-alt = "#737E9C"; # 装饰/禁用文本（随底色提亮，保持原可读档位）
  accent = "#649AFA";    # 主强调（logo 紫蓝渐变中段）：btop/fzf/fuzzel/Bibata 重着色等
  accent-2 = "#8B93F8";  # 交互强调（紫蓝再提亮）：菜单高亮、fzf 提示、zathura 搜索
  accent-bright = "#9DC4FD";        # 更亮的蓝，稀疏高亮
  accent-yellow-bright = "#C3CBFF"; # 强调文本的亮蓝紫（键名沿用旧结构）
  accent-deep = "#415E9A";          # logo 深蓝渐变起点：图表起点等深色装饰
  accent-bg = "#414868";            # 选区背景（ghostty selection）；壁纸最亮块再提亮一档
  cursor = "#DDE4F3";               # 光标颜色（ghostty cursor-color）
  black = "#1E2030";     # 最深表面；亮色强调上的文字；壁纸基底色

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

  # --- 终端浅色 variant（ghostty 的 light theme 专用）---
  # 其他消费者（btop/zathura/fzf 等）仍用上面的深色语义色；这份色板只给
  # ghostty 的 paired theme 用。普通 ANSI 色对 #EDF0F8 的对比度均 ≥ 4.5，
  # bright 组刻意压深（浅底上「更亮」会变得更难读）。
  terminal-light = {
    bg = "#EDF0F8";
    fg = "#2E3246";
    cursor = "#415E9A";
    selection-bg = "#C7D4F2";
    selection-fg = "#1E2030";
    ansi = {
      black = "#393D52";
      red = "#A84A52";
      green = "#356E47";
      yellow = "#7E5C12";
      blue = "#355FB8";
      magenta = "#7659B8";
      cyan = "#266B79";
      white = "#C6CFE2";
    };
    ansi-bright = {
      black = "#5B6488";
      red = "#9A3F49";
      green = "#2F6441";
      yellow = "#6F510D";
      blue = "#2F55A8";
      magenta = "#684BA8";
      cyan = "#215E6B";
      white = "#B8C4DA";
    };
  };
}
