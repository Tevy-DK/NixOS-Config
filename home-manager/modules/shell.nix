{ config, pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.fish = {
    enable = true;
    
    # 关闭欢迎信息
    interactiveShellInit = ''
      set fish_greeting
    '';
  };
}
