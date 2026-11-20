# 全局主题（desktop-hyprland）：Nix Periwinkle，静态兜底。
# 主题归属：Hyprland 运行期应用配色（写入者：Caelestia 壁纸方案 ——
#   gtk/hypr/btop 由 Caelestia CLI 写，ghostty/cava 由 lib/caelestia-apps.nix
#   的 postHook 写，home/hyprland.lua 读 hypr/scheme/current.lua 画边框）。
# 本文件是静态兜底 + fastfetch/zathura/mpv/fzf/bat 的色源：Caelestia 的
# 深浅模式切换时这几个工具不跟随；scheme.json/current.lua 缺失时
# caelestia-apps 也用它兜底。
#
# borders-plus-plus 的玻璃边框是写死的半透明白（home/hyprland.lua），
# 不参与这里求值。
#
# 与 system/theme.nix 的差异只有两处：
#   1. 补齐 caelestia-apps 静态兜底要的 ansi-bright（niri 侧由 Noctalia
#      模板接管，不需要这个键）；
#   2. 字体/光标沿用当前值，避免和共享的 home/*.nix 分叉。
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
  bg = "#2E3246";        # 主背景；zathura 等静态消费（btop/Hyprland 运行期归 Caelestia）
  bg-alt = "#393D52";    # 凸起表面（选中项 / 侧栏）
  fg = "#D4DCEC";        # 主前景
  fg-bright = "#E6ECF8"; # 强调前景
  muted = "#9AA7C4";     # 次要可读文本
  muted-alt = "#737E9C"; # 装饰/禁用文本（btop 边框运行期归 Caelestia）
  accent = "#649AFA";    # 主强调；fzf 等静态消费（Hyprland 活动边框运行期归 Caelestia）
  accent-2 = "#8B93F8";  # 交互强调；fzf 提示、zathura 搜索
  accent-bright = "#9DC4FD";        # 更亮的蓝，稀疏高亮
  black = "#1E2030";                # 最深表面；壁纸基底

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
