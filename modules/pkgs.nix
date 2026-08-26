{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
  wget
  fastfetch
  wayland-utils
  quickshell
  qt6.qtwayland
 ];
}
