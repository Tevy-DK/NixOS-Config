# --- clipboard ---
# 剪贴板历史：clipse TUI（沿用 hyprland-recovery 的做法，取代 cliphist + 菜单选择器）。
# services.clipse 自带 -listen 守护进程（systemd 用户服务，随图形会话启动）；
# Mod+V 用 ghostty 浮窗调起，浮窗规则见 hyprland.lua 的 com.dk.clipse。
# 仅 hyprland 档案加载（niri 档案在 flake.nix 里覆盖为 false，noctalia 自带剪贴板面板）。
{ ... }:
{
  services.clipse = {
    enable = true;
    settings = {
      maxHistory = 100;
      allowDuplicates = false;
    };
  };
}
