# home.nix
{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    # 通过 Nix 声明式地安装插件
    plugins = with pkgs.vimPlugins; [
    ];
  };

  # 将你本地的 IceNvim 配置文件夹链接到 ~/.config/nvim
  xdg.configFile."nvim".source = ./nvim;
}
