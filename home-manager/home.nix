{ config, pkgs, inputs, ... }:

{
  # 1. 你的用户名和家目录绝对路径
  home.username = "dk";
  home.homeDirectory = "/home/dk";
  # 2. 触发安装时的系统版本号（保持不动即可）
  home.stateVersion = "26.05";
  # 3. 允许 Home-Manager 管理它自己
  programs.home-manager.enable = true;
  imports = [
    ./modules/pkgs.nix
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/starship.nix
    ./modules/themes.nix
    ./modules/caelestia.nix
    ./modules/hyprland.nix
    ./modules/services.nix
    ./modules/ghostty.nix
    ./modules/yazi.nix
    ./modules/nvim.nix
    ./modules/hyprshot.nix
    ./modules/cava.nix
    ./modules/code.nix
  ];
}
