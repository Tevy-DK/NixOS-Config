# --- clipboard ---
# 剪贴板历史：clipse TUI（沿用 hyprland-recovery 的做法，取代 cliphist + 菜单选择器）。
# services.clipse 自带 -listen 守护进程（systemd 用户服务，随图形会话启动）；
# Mod+V 用 ghostty 浮窗调起，浮窗规则见 niri config.kdl 的 com.dk.clipse。
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
