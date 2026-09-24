{ inputs, pkgs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = false;

    settings = {
      shell = {
        font = "JetBrainsMono Nerd Font";
        settings_show_advanced = true;
        settings_window_translucent = true;
      };
      general = {
        transparency_mode = "glass";
      };
      theme = {
        mode = "auto";
        source = "wallpaper";
        wallpaper_scheme = "m3-content";
        shell_mode = "follow";
      };

      backdrop = {
        enabled = true;
        blur_intensity = 0.65;
        tint_intensity = 0.18;
      };

      location = {
        auto_locate = true;
      };
    };
  };
}
