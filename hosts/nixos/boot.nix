{ config, pkgs, inputs, ... }:
{
  boot.loader = {
    grub = {
      enable = true;
      device = "/dev/nvme0n1";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    efi.canTouchEfiVariables = false;
  };
  boot.kernelPackages = pkgs.linuxPackages_zen;
}
