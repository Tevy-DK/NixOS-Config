{ ... }:
{
  programs.cava.enable = true;
  xdg.configFile."cava/config".source = ./cava-config;
}
