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
    # PATH
    shellInit = ''
      fish_add_path ~/.local/bin
      # distrobox 容器共享宿主 HOME 和 /nix，但 PATH 不含 NixOS 的用户环境；
      # 宿主的 fish 配置会 source fzf 快捷键、eza/bat 别名，容器里找不到就报
      # “fzf was not found in path.”。/run/host 是 distrobox 挂载的宿主根目录，
      # /etc/static 指向当前系统的 etc（其中 profiles/per-user 是用户包环境）。
      if test -d /run/host/etc/static/profiles/per-user/$USER
        fish_add_path --global /run/host/etc/static/profiles/per-user/$USER/bin
      end
    '';
    # 命令别名
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      nfu = "cd /etc/nixos; and nix flake update";
      ncgd = "sudo nix-collect-garbage -d";
    };
  };
}
