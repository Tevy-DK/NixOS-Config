# --- caelestia-shell 用户层（恢复自 hyprland-recovery 分支）---
# Hyprland 桌面的状态栏/启动器/通知中心（quickshell 全家桶），
# 只在 desktop = "hyprland" 的机器上随 home/hyprland.nix 一起启用。
# 主题覆盖 shell.json：extraConfig 整份来自 ./shell.json。
{ config, pkgs, inputs, ... }:
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;
    package = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli;
    systemd = {
      enable = true; # 从合成器启动而不是自带的 systemd 单元
      target = config.wayland.systemd.target;
      environment = [ ];
    };
    extraConfig = builtins.readFile ./shell.json;

    cli = {
      enable = true; # 确保 CLI 被安装
      settings = {
        theme.enableGtk = true;
      };
    };
  };
}
