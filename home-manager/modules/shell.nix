{ config, pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "nano";
  };

  programs.fish = {
    enable = true;
    
    # 关闭欢迎信息
    interactiveShellInit = ''
      set fish_greeting
    '';
  };
}
