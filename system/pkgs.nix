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
  # （通知/锁屏由 noctalia 接管：noctalia 自带 notification daemon 与 lockscreen，
  #   mako 和 swaylock 已随外壳替换移除，见 system/niri.nix 的 programs.noctalia）
  wl-clipboard     # wl-copy / wl-paste（nvim 系统剪贴板等）
  brightnessctl    # CLI 亮度兜底（桌面键位走 noctalia msg brightness-*）
  playerctl        # CLI 媒体控制兜底（桌面键位走 noctalia msg media *）
  wireplumber      # PipeWire 会话管理，wpctl 也由它提供
  libnotify        # notify-send
  fzf              # sysmenu 依赖
  btop             # 系统监控
  ];
}
