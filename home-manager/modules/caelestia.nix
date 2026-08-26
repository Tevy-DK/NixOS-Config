{ pkgs, inputs, ... }:
{
    imports = [
      inputs.caelestia-shell.homeManagerModules.default
    ];
    programs.caelestia = {
      enable = true;
      package = inputs.caelestia-shell.packages.${pkgs.system}.with-cli;
      systemd = {
        enable = false; # if you prefer starting from your compositor
        target = "graphical-session.target";
        environment = [];
      };
      extraConfig = builtins.readFile ./shell.json;
   
      cli = {
        enable = true;               # 这会确保包被安装
        settings = {                 # 如果有单独的 CLI 配置，可以在这里设置
          theme.enableGtk = true;
        };
      };
    };
}
