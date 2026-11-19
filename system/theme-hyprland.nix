# 全局主题（desktop-hyprland）：Nix Periwinkle。
#
# desktop-niri 的配色由 Noctalia 从壁纸生成（见 system/theme.nix 的注释），
# Caelestia Shell 没有同款“把调色板分发给所有应用”的声明式模板，所以
# Hyprland 机器继续用同一代的静态 theme.nix：颜色在这里是唯一来源，
# home/hyprland-theme.nix 把它渲染给 btop/cava/ghostty，
# home/hyprland.nix 把普通 Hyprland 边框色替换进 home/hyprland.lua；
# borders-plus-plus 的两层边框使用 Lua 里的静态半透明玻璃色，不参与求值。
#
# 与 system/theme.nix 的差异只有三处：
#   1. 补齐旧版消费方要的派生色（accent-deep/accent-bg/cursor/border/
#      ansi-bright），niri 侧已由 Noctalia 模板接管，不需要这些键；
#   2. 字体/光标沿用当前值，避免和共享的 home/*.nix 分叉；
#   3. 注释写明消费方，删掉已不存在的 fuzzel/GTK 颜色链路。
{
  # --- 字体 ---
  # 与 desktop-niri 保持一致：Cascadia Code 的 Nerd 补丁变体。
  # Fira Code 只在 VSCodium 内使用，见 home/vscodium.nix。
  font = "Cascadia Code NF";
  font-size = 12;     # 终端字号
  font-size-ui = 11;  # GTK 界面字号
  font-size-bar = 12; # zathura / swayimg 等小界面字号

  # --- 光标 ---
  # 原版 Bibata Modern Ice（nixpkgs 的 bibata-cursors），固定不随模式切换。
  cursor-name = "Bibata-Modern-Ice";
  cursor-size = 24;

  # --- 语义色（Nix Periwinkle）---
  bg = "#2E3246";        # 主背景；zathura / btop / Hyprland shadow
  bg-alt = "#393D52";    # 凸起表面（选中项 / 侧栏）
  fg = "#D4DCEC";        # 主前景
  fg-bright = "#E6ECF8"; # 强调前景
  muted = "#9AA7C4";     # 次要可读文本
  muted-alt = "#737E9C"; # 装饰/禁用文本；btop 边框
  accent = "#649AFA";    # 主强调；Hyprland 活动边框
  accent-2 = "#8B93F8";  # 交互强调；fzf 提示、zathura 搜索
  accent-bright = "#9DC4FD";        # 更亮的蓝，稀疏高亮
  accent-deep = "#415E9A";          # logo 深蓝渐变起点；btop 图表起点
  accent-bg = "#414868";            # 选区背景；壁纸最亮块再提亮一档
  cursor = "#DDE4F3";               # 光标颜色；ghostty cursor-color
  black = "#1E2030";                # 最深表面；壁纸基底
  border = "#4A506B";               # 非活动窗口边框

  # --- ANSI normal 8 色（Nix Periwinkle 终端色；蓝/青取自 logo 渐变）---
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

  # --- ANSI bright 8 色 ---
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
