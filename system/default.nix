# 系统层共享模块清单（借鉴 koru system/default.nix）：显式导入，机器无关。
# 机器专属配置（硬件/引导/地区/账户/代理）在 hosts/<名字>/，主题在 ./theme.nix。
# 桌面环境模块二选一：由 flake.nix 按 inventory 里每台机器的 desktop 字段门控。
{ lib, desktop, ... }:

{
  imports = [
    ./config.nix
    ./fcitx5.nix
    ./fonts.nix
    ./journal.nix
    ./memory.nix
    ./network.nix
    ./nix-ld.nix
    ./pkgs.nix
    ./security.nix
    ./services.nix
    ./settings.nix
    ./shell.nix
  ] ++ lib.optional (desktop == "niri") ./niri.nix
    ++ lib.optional (desktop == "hyprland") ./hyprland.nix;
}
