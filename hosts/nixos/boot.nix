{ config, pkgs, inputs, ... }:
{
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    efi.canTouchEfiVariables = false;
  };
  boot.kernelPackages = pkgs.linuxPackages_zen;
}
