{ config, pkgs, inputs,... }:
{
  wayland.windowManager.hyprland = {
    enable = true;          # ⚠️ 必须保留 true，否则不会生成你的配置文件！

    package = null;         # ✅ 告诉 HM 不要自己安装 Hyprland，用系统的
    portalPackage = null;   # ✅ 告诉 HM 不要自己安装 Portal，用系统的
    plugins = [
    	inputs.hyprland-scroll-overview.packages.${pkgs.system}.scrolloverview
    ];
    extraLuaFiles = {
      "config" = {
        content = ./hyprland.lua;
        autoLoad = true;
      };
    };
  };
}
