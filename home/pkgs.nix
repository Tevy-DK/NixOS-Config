{ pkgs, config, inputs, ... }:
{
  home.packages = with pkgs; [
    #termusic
    google-chrome
    tela-icon-theme
    obs-studio
    marktext
    qq
    wechat
    nautilus
    nautilus-python
    uv
    # 自建 flake：SJMCL 启动器（Tevy-DK-attic，home-manager 用户级安装）
    inputs.tevy-dk-attic.packages.${pkgs.stdenv.hostPlatform.system}.sjmcl
    # 自建 flake：Motrix 下载器与 balenaEtcher 镜像写入工具
    inputs.tevy-dk-attic.packages.${pkgs.stdenv.hostPlatform.system}.motrix
    inputs.tevy-dk-attic.packages.${pkgs.stdenv.hostPlatform.system}.etcher
    chatgpt
    cc-switch
  ];
}
