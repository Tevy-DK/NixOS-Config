{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
  wget
  fastfetch
  wayland-utils
  mmtui #yazi mount用的
  ripgrep
  fd
  gcc
  cmake
  unzip
  nodejs
  yarn
  python3
  tree-sitter
  bun
  lua

  # 桌面基础设施：niri 直接按名字 spawn，必须在系统 PATH
  mako             # 通知守护进程（dbus 激活，无常驻面板）
  wl-clipboard     # wl-copy / wl-paste（nvim 系统剪贴板等）
  brightnessctl
  playerctl
  wireplumber      # 提供 wpctl（音量控制）
  swaylock         # 锁屏（PAM 由 niri 的 wayland-session 提供）
  libnotify        # notify-send
  fzf              # sysmenu 依赖
  btop             # scratch 仪表盘 / 系统监控
  ];
}
