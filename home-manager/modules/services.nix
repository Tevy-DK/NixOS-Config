{ config, pkgs, ... }:
{
  services.clipse = {
    enable = true;

    settings = {
      maxHistory = 100;
      allowDuplicates = false;
    };
  };
}
