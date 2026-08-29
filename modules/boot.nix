{ config, pkgs, inputs, ... }:
let
  cachyos = inputs.nix-cachyos-kernel.packages.${pkgs.system};
in {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackagesFor cachyos.linux-cachyos-bore-lto-x86_64-v3;
}
