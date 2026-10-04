# --- 系统层 Hyprland ---
# 只在 inventory 里 desktop = "hyprland" 的机器上由 system/default.nix 导入。
# 主程序与 portal 都取自 nixpkgs（与 hyprland-recovery 分支一致，不用 flake 钉版）；
# 用户层配置在 home/hyprland.nix + home/caelestia.nix。
{ ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # ly 不显示会话选择，直接进 Hyprland（recovery 分支同款行为）
  services.displayManager.ly.settings = {
    start_cmd = "start-hyprland";
    hide_session_selection = true;
  };
}
