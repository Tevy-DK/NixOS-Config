# --- caelestia-shell 用户层（恢复自 hyprland-recovery 分支）---
# Hyprland 桌面的状态栏/启动器/通知中心（quickshell 全家桶），
# 只在 desktop = "hyprland" 的机器上随 home/hyprland.nix 一起启用。
# 主题覆盖 shell.json：extraConfig 整份来自 ./shell.json。
#
# GTK 外观：与 niri 的 gtk.nix 互斥（flake.nix 档案开关），这里显式声明与
# niri 同一套的 dconf 基础键（主题/字体/暗色/图标），颜色则由 caelestia
# theme.enableGtk 在运行时按壁纸生成 gtk.css 覆盖。两侧同写这批键的原因：
# HM 切换代际不会清除不再管理的 dconf 键，若只有 niri 声明，切到 hyprland
# 会残留 niri 的值——显式同写后两个环境的 GTK 基础设置完全一致，互不影响。
{ pkgs, inputs, theme, ... }:
{
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
  ];

  programs.caelestia = {
    enable = true;
    package = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.with-cli;
    # 不生成 caelestia-shell systemd 用户单元，改由 Hyprland 启动时直接拉起
    #（caelestia shell -d，见 home/hyprland.lua 的 AUTOSTART）
    systemd.enable = false;
    extraConfig = builtins.readFile ./shell.json;

    cli = {
      enable = true; # 确保 CLI 被安装
      settings = {
        theme.enableGtk = true;
      };
    };
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      name = "adw-gtk3-dark"; # 运行时壁纸配色会以 gtk.css 覆盖其命名色
      package = pkgs.adw-gtk3;
    };
    font = {
      name = theme.font;
      size = theme.font-size-ui;
    };
    iconTheme = {
      name = "Tela";
      package = pkgs.tela-icon-theme;
    };
  };
}
