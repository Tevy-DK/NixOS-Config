{ pkgs, config, inputs, ... }:
{
  home.packages = with pkgs; [
    termusic
    google-chrome
    tela-icon-theme
    obs-studio
    marktext
    qq
    wechat
    nautilus
    nautilus-python
    uv
    # 自建 flake：SJMCL 启动器（home-manager 用户级安装）
    inputs.sjmcl-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
