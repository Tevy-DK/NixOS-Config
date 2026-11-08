{ pkgs, ... }:
let
  # nixpkgs 的 host-spawn 没注入版本号（--version 打印 HEAD），
  # 而 distrobox-host-exec 用版本号决定要不要联网重新下载 host-spawn：
  # 版本对不上就下载，GitHub 不通时每次调用都卡住重试再失败。
  # 这里把真实版本写进二进制，让版本检查通过，直接复用宿主装好的这一份。
  host-spawn = pkgs.host-spawn.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace main.go \
        --replace-fail 'var Version string = "HEAD"' 'var Version string = "v${old.version}"'
    '';
  });
in
{
  # Podman：无守护进程的容器引擎，rootless 模式开箱即用。
  # dockerCompat 提供 docker -> podman 的命令别名，兼容按 docker 调用的脚本/工具。
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # distrobox 基于 Podman 创建各发行版容器，命令需在系统 PATH 直接可用。
  # host-spawn 负责从容器内执行宿主命令（distrobox 的 XAUTHORITY/DISPLAY 转发、
  # xdg-open、distrobox-host-exec 都依赖它）；容器内 /usr/bin/host-spawn 由
  # home/distrobox.nix 的 init_hooks 指向这里的系统 profile。
  environment.systemPackages = [
    pkgs.distrobox
    host-spawn
  ];
}
