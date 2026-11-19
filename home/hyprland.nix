# --- Hyprland 用户层（恢复自 hyprland 分支）---
# 主程序与 portal 由系统层 system/hyprland.nix 安装（package = null），
# 这里只负责用户配置：hyprland.lua（Lua 版配置）+ borders-plus-plus 插件
# + 截图 + 认证代理。
#
# 普通 Hyprland 边框色从 system/theme-hyprland.nix 注入：Lua 文件保留
# @accent@ 之类占位符，HM 求值时替换。borders-plus-plus 自己用静态半透明
# 玻璃色，不参与 theme 颜色求值。
{ lib, pkgs, theme, ... }:
let
  hex = color: lib.toLower (lib.removePrefix "#" color);

  rgba = color: alpha: "rgba(${hex color}${alpha})";

  luaConfig = builtins.replaceStrings
    [
      "@accent@"
      "@accent-2@"
      "@accent-bright@"
      "@border@"
      "@shadow@"
    ]
    [
      (rgba theme.accent "ff")
      (rgba theme.accent-2 "ff")
      (rgba theme.accent-bright "ff")
      (rgba theme.border "aa")
      "0xee${hex theme.black}"
    ]
    (builtins.readFile ./hyprland.lua);
in
{
  wayland.windowManager.hyprland = {
    enable = true;          # ⚠️ 必须保留 true，否则不会生成你的配置文件！

    package = null;         # ✅ 告诉 HM 不要自己安装 Hyprland，用系统的
    portalPackage = null;   # ✅ 告诉 HM 不要自己安装 Portal，用系统的

    # 这里只声明 borders-plus-plus 的包路径；HM 据此在生成的
    # hyprland.lua 里先 hl.plugin.load，再 require config。插件配置全部
    # 在 home/hyprland.lua 的 plugin.borders_plus_plus 节点，不写在 Nix 里。
    plugins = [ pkgs.hyprlandPlugins.borders-plus-plus ];

    extraLuaFiles = {
      "config" = {
        content = luaConfig;
        autoLoad = true;
      };
    };
  };

  # 截图：hyprland.lua 里 Mod+Shift+S（区域）/ Mod+Shift+Alt+S（窗口）绑定
  programs.hyprshot = {
    enable = true;
    saveLocation = "$HOME/Pictures/Screenshots";
  };

  # 认证弹窗代理（旧 hyprland 环境同款；polkit 本体在 system/security.nix）
  services.hyprpolkitagent.enable = true;
}
