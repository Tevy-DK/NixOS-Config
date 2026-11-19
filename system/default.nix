# 系统层共享模块清单（借鉴 koru system/default.nix）：显式导入，机器无关。
# 机器专属配置（硬件/引导/地区/账户/代理）在 hosts/<名字>/。
# 桌面环境模块由 flake.nix 按 inventory 里每台机器的 desktop 字段门控：
#   niri     → niri + noctalia-greeter
#   hyprland → Hyprland + ly（黑洞动画）
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
    ./podman.nix
    ./security.nix
    ./services.nix
    ./settings.nix
    ./shell.nix
    ./sunshine.nix
  ] ++ lib.optionals (desktop == "niri") [
    ./niri.nix
    ./greeter.nix
  ] ++ lib.optionals (desktop == "hyprland") [
    ./hyprland.nix
    ./ly.nix
  ];
}
