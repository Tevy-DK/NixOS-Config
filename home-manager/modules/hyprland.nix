{ config, pkgs, hyprland, hyprland-plugins,... }:
{
  wayland.windowManager.hyprland = {
    enable = true;          # ⚠️ 必须保留 true，否则不会生成你的配置文件！

    package = null;         # ✅ 告诉 HM 不要自己安装 Hyprland，用系统的
    portalPackage = null;   # ✅ 告诉 HM 不要自己安装 Portal，用系统的
    plugins = with pkgs.hyprlandPlugins; [
    ];
  };
  xdg.configFile."hypr/hyprland.lua".source = ./hyprland.lua;
}
