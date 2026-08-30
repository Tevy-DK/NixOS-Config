{ config, pkgs, ... }:

{
  /*nixpkgs.hostPlatform = "x86_64-linux";
  fileSystems."/" = {
  device = "/dev/sdd";
  fsType = "ext4";
  };*/

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/i18n.nix
      ./modules/config.nix
      ./modules/services.nix
      ./modules/settings.nix
      ./modules/boot.nix
      ./modules/pkgs.nix
      ./modules/fonts.nix
      ./modules/user.nix
      ./modules/network.nix
      ./modules/memory.nix
      ./modules/shell.nix
      ./modules/hyprland.nix
      ./modules/nix-ld.nix
      ./modules/clash.nix
    ];
  system.stateVersion = "26.05";
}
