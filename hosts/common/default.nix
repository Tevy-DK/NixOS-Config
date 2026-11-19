# 同一台物理机共用的主机层（不是 inventory 里的机器）：
# 硬件、引导、地区、登录账户、代理等与桌面无关的设置。
#
# hosts/desktop-niri 和 hosts/desktop-hyprland 都 import 本目录，各自只
# 决定 desktop 档案；flake.nix 仍按 inventory 的键生成独立系统。
# 新物理机不要复用本目录，应给自己复制一份并替换 hardware-configuration.nix。
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
