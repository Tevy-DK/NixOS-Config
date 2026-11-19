# 娱乐环境主机（desktop-hyprland）：与 desktop-niri 是同一台物理机的
# 两个桌面档案。硬件/引导/地区/账户/代理统一在 hosts/common，两个主机
# 目录只保留“这一台机器选哪个桌面”的薄层，互不引用对方。
#
# 如果以后是另一台不同硬件的机器，不要改 hosts/common；新建 hosts/<名字>/，
# 放自己的 hardware-configuration.nix / boot.nix / locale.nix 等，不要 import ../common。
{ ... }:

{
  imports = [ ../common ];
}
