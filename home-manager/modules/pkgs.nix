{ pkgs, config, inputs, ... }:
{
  home.packages = with pkgs; [
    termusic
    google-chrome
    hmcl
    tela-icon-theme
    vscode
    obs-studio
    wl-clipboard
    hyprpolkitagent

  ];
}
