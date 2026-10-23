{ config, pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.fish = {
    enable = true;
    
    # 关闭欢迎信息
    interactiveShellInit = ''
      set fish_greeting ""
    '';
    # 可执行文件路径
    shellInit = ''
      fish_add_path ~/.local/bin
    '';
    # 命令别名
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      nfu = "cd /etc/nixos; and nix flake update";
      ncgd = "sudo nix-collect-garbage -d";
    };
  };
}
