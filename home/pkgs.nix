{ pkgs, config, inputs, ... }:
{
  home.packages = with pkgs; [
    termusic
    google-chrome
    hmcl
    tela-icon-theme
    obs-studio
    marktext
    qq
    nautilus
    oh-my-posh  # 提示符引擎（命令 omp）
  ];
}
