# --- 系统层 Hyprland ---
# 只在 inventory 里 desktop = "hyprland" 的机器上由 system/default.nix 导入。
# 主程序与 portal 都取自 nixpkgs（与 hyprland 分支一致，不用 flake 钉版）；
# 用户层配置在 home/hyprland.nix + home/caelestia.nix。
{ ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}
