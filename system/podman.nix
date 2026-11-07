{ pkgs, ... }:
{
  # Podman：无守护进程的容器引擎，rootless 模式开箱即用。
  # dockerCompat 提供 docker -> podman 的命令别名，兼容按 docker 调用的脚本/工具。
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # distrobox 基于 Podman 创建各发行版容器，命令需在系统 PATH 直接可用。
  environment.systemPackages = with pkgs; [
    distrobox
  ];
}
