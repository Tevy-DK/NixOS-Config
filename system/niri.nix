{ pkgs, inputs, ... }:
{
  programs.niri.enable = true;

  # Noctalia v5 桌面外壳（原生 Wayland 实现，nixpkgs 26.04 自带包与模块）：
  # bar / 启动器 / 控制中心 / 通知 / OSD / 托盘 / 剪贴板历史 / 锁屏 / 会话菜单 /
  # 壁纸 / polkit 认证弹窗 全套由它接管，不再用 fuzzel/awww/tray-tui/mako/swaylock。
  # 用户侧 config.toml（玻璃面板、概览模糊壁纸、壁纸目录等）在 home/noctalia.nix。
  programs.noctalia = {
    enable = true;
    systemd.enable = true; # 用户服务随 graphical-session.target 拉起
    recommendedServices.enable = true; # NetworkManager / bluetooth / upower / power-profiles-daemon
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config = {
      common.default = [ "gnome" ];
    };
  };
}
