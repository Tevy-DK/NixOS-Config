# 主机清单（借鉴 koru hosts/inventory.nix）。
# flake.nix 会为这里的每个条目自动生成：
#   nixosConfigurations.<名字>   完整系统（sudo nixos-rebuild switch --flake .#<名字>）
#   homeConfigurations.<名字>   独立用户层（home-manager switch --flake .#<名字>）
#
# 字段：
#   username  登录用户
#   system    CPU 架构
#   desktop   桌面环境档案（缺省 niri），可选值见 flake.nix 的 desktopProfiles：
#               niri = niri + noctalia 外壳（工作环境）
#
# 新增机器的步骤：
#   1. 复制 hosts/nixos/ 为 hosts/<新名字>/
#   2. 替换其中的 hardware-configuration.nix（在目标机器上 nixos-generate-config 生成）
#   3. 按硬件改 boot.nix（磁盘设备！）、locale.nix，按需增删模块
#   4. 在这里加一个条目
{
  # 工作环境：这台物理机的主机层（硬件/引导/地区/账户/代理）在这里维护。
  # hostname 跟着清单键名走（networking.hostName = 键名）。
  nixos = {
    username = "dk";
    system = "x86_64-linux";
    desktop = "niri";
  };

  # 示例：另一台不同硬件的机器
  # laptop = {
  #   username = "dk";
  #   system = "x86_64-linux";
  #   desktop = "niri";
  # };
}
