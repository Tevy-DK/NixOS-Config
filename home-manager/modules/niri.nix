{ config, pkgs, inputs,... }:
{
  wayland.windowManager.niri = {
    enable = true;
    package = null;
    extraLuaFiles = {
      "config" = {
        content = ./config.kdl;
        autoLoad = true;
      };
    };
  };
}
