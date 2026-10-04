# 娱乐环境主机（hosts/hyprland）：与 niri 是同一台物理机，所以硬件/引导/
# 地区/账户/代理整套复用 hosts/niri；桌面差异只由 inventory.nix 里
# desktop 字段决定（hyprland → Hyprland + caelestia，niri → niri）。
# 如果以后是另一台不同硬件的机器，请复制 hosts/niri/ 并替换
# hardware-configuration.nix，而不是这样引用。
{ ... }:

{
  imports = [ ../niri ];
}
