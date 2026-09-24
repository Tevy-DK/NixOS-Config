{ config, pkgs, inputs,... }:
{
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
}
