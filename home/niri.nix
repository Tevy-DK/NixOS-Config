# --- niri 用户层（工作环境）---
{ config, pkgs, inputs, ... }:
{
  xdg.configFile."niri/config.kdl".source = ./config.kdl;

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
