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
#   - fastfetch / zathura / fzf / bat / fuzzel / 光标包：引用本文件
#   - ghostty/btop/cava：配色由 noctalia 内置模板生成（壁纸取色），本文件不参与
#   - GTK/Qt/niri 窗口配色：由 noctalia 内置模板生成（见 home/noctalia.nix）
#   - GTK 主题名：由 noctalia 的 gtk 模板按模式选 adw-gtk3 / adw-gtk3-dark
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
  # 桌面会话由 Noctalia hooks 触发 cursor-theme-sync 按解析后的模式切换；
  # 登录页没有运行时切换，固定用 dark。
  cursor-name-dark = "Bibata-Modern-Dark";
  cursor-name-light = "Bibata-Modern-Light";
  # 稳定别名：cursor-theme-sync 在 ~/.local/share/icons 维护一个指向当前
  # dark/light 主题的符号链接。XCURSOR_THEME 固定写别名，niri 每次 spawn
  # 子进程时都会重新读取，不必因为模式切换而重启 niri。已经在运行的旧进程
  # 若还持有具体 dark/light 名字，需要重启一次才会改用别名。
  cursor-alias = "Bibata-Modern-Current";
  cursor-size = 24;

  # --- 语义色（Nix Periwinkle）---
  bg = "#2E3246";        # 主背景；壁纸浅色块（雪花亮带）；niri backdrop 兜底 / zathura
  bg-alt = "#393D52";    # 凸起表面（选中项 / 侧栏）；壁纸轮廓高光色
  fg = "#D4DCEC";        # 主前景
  fg-bright = "#E6ECF8"; # 强调前景
  muted = "#9AA7C4";     # 次要可读文本
  muted-alt = "#737E9C"; # 装饰/禁用文本（随底色提亮，保持原可读档位）
  accent = "#649AFA";    # 主强调（logo 紫蓝渐变中段）：fzf/fuzzel 等
  accent-2 = "#8B93F8";  # 交互强调（紫蓝再提亮）：菜单高亮、fzf 提示、zathura 搜索
  accent-bright = "#9DC4FD";        # 更亮的蓝，稀疏高亮
  black = "#1E2030";     # 最深表面；亮色强调上的文字；壁纸基底色

  # --- ANSI normal 8 色（Nix Periwinkle 终端色；蓝/青直接取 logo 渐变）---
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

}
