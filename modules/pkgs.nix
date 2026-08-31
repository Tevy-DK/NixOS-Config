{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
  wget
  fastfetch
  wayland-utils
  quickshell
  qt6.qtwayland
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
  zig
  gnumake
  ];
}
