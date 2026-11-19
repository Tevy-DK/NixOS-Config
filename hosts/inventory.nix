# 主机清单（借鉴 koru hosts/inventory.nix）。
# flake.nix 会为这里的每个条目自动生成：
#   nixosConfigurations.<名字>   完整系统（sudo nixos-rebuild switch --flake .#<名字>）
#   homeConfigurations.<名字>   独立用户层（home-manager switch --flake .#<名字>）
#
# 字段：
#   username  登录用户
#   system    CPU 架构
#   desktop   桌面环境档案（缺省 niri），可选值见 flake.nix 的 desktopProfiles：
#               niri     = niri + noctalia 外壳（工作环境）
#               hyprland = Hyprland + Caelestia + clipse（娱乐环境）
#
# 新增机器的步骤：
#   1. 在 hosts/<新名字>/ 放主机层；可从 hosts/common/ 复制与桌面无关的
#      boot/locale/user-account/clash/hardware 配置
#   2. 替换 hardware-configuration.nix（在目标机器上 nixos-generate-config 生成）
#   3. 按硬件改 boot.nix（磁盘设备！）、locale.nix，按需增删模块
#   4. 在这里加一个条目
{
  # 工作环境：与 desktop-hyprland 同一台物理机，共用 hosts/common。
  # hostname 跟着清单键名走（networking.hostName = 键名）。
  desktop-niri = {
    username = "dk";
    system = "x86_64-linux";
    desktop = "niri";
  };

  # 娱乐环境：与 desktop-niri 同一台物理机，共用 hosts/common，只有桌面不同。
  # 切到 Hyprland：sudo nixos-rebuild switch --flake .#desktop-hyprland
  # 切回 niri：          sudo nixos-rebuild switch --flake .#desktop-niri
  # 注意：hostname 跟着清单键名走，切环境后机器名会变。
  desktop-hyprland = {
    username = "dk";
    system = "x86_64-linux";
    desktop = "hyprland";
  };

  # 示例：另一台不同硬件的机器
  # laptop = {
  #   username = "dk";
  #   system = "x86_64-linux";
  #   desktop = "niri";
  # };
}
