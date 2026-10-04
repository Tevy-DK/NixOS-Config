# --- niri 用户层（工作环境）---
{ config, pkgs, inputs, ... }:
{
  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  # TUI 托盘（Mod+Y）：niri 环境没有状态栏，clash-verge / fcitx5 的
  # StatusNotifierItem 图标和菜单需要一个宿主，tray-tui 在终端里当这个宿主。
  # hyprland 环境不装：caelestia 的栏自带托盘。
  home.packages = [ pkgs.tray-tui ];

  # polkit 认证弹窗代理（GTK 版；起法与 home/hyprland.nix 的 hyprpolkitagent 同款）
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome Authentication Agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
