{ config, pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    package = pkgs.yazi.override {
      _7zz = pkgs._7zz-rar;
    };
    plugins = {
      inherit (pkgs.yaziPlugins) mediainfo git mount;
    };
    extraPackages = with pkgs; [
      file
      imagemagick
      resvg
      ffmpeg
      mmtui
    ];
    keymap = {
      mgr.prepend_keymap = [
        {
          on = "M";                          # 按 m 键
          run = "plugin mount";              # 调用 mount 插件
          desc = "Mount / unmount device";   # 描述（在帮助中显示）
        }
      ];
    };
  };
}
