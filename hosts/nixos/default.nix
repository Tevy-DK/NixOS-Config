# 主机层（借鉴 koru hosts/koru/default.nix）：
# 这台机器专属的硬件、引导、地区、账户与代理。
# 机器无关的系统模块在 ../../system/default.nix，由 flake.nix 并入。
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./locale.nix
    ./user-account.nix
    ./clash.nix
  ];

  system.stateVersion = "26.05";
}
