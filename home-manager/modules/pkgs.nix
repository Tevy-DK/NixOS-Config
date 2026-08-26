{ pkgs, config, inputs, ... }:
{
  home.packages = with pkgs; [
    termusic
    google-chrome
    clash-verge-rev
    hmcl
    kdePackages.dolphin
    tela-icon-theme
    wl-clipboard
    vscode
  ];
}
