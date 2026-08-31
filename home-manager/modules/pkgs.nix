{ pkgs, config, inputs, ... }:
{
  home.packages = with pkgs; [
    termusic
    google-chrome
    hmcl
    tela-icon-theme
    obs-studio
    wl-clipboard
  ];
}
