# --- Hyprland 用户层 ---
# 结构参照 hyprland 分支：一个 hyprland.nix 负责 HM 的 Hyprland 模块
# （配置入口、插件加载、截图、认证代理），实际配置全在 hyprland.lua。
# borders-plus-plus 只在这里声明插件包；插件参数在 hyprland.lua。
#
# 普通 Hyprland 边框色从 system/theme-hyprland.nix 注入：Lua 文件保留
# @accent@ 之类占位符，HM 求值时替换。
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
      "@caelestiaShell@"
    ]
    [
      (rgba theme.accent "ff")
      (rgba theme.accent-2 "ff")
      (rgba theme.accent-bright "ff")
      (rgba theme.border "aa")
      "0xee${hex theme.black}"
      "${pkgs.caelestia-shell}/bin/caelestia-shell"
    ]
    (builtins.readFile ./hyprland.lua);
in
{
  wayland.windowManager.hyprland = {
    enable = true;          # ⚠️ 必须保留 true，否则不会生成你的配置文件！

    package = null;         # ✅ 告诉 HM 不要自己安装 Hyprland，用系统的
    portalPackage = null;   # ✅ 告诉 HM 不要自己安装 Portal，用系统的

    plugins = [ pkgs.hyprlandPlugins.borders-plus-plus ];

    extraLuaFiles = {
      "config" = {
        content = luaConfig;
        autoLoad = true;
      };
    };
  };

  # Hyprland 首次启动若在 HM 激活前发生，会自己生成
  # ~/.config/hypr/hyprland.lua；HM 激活随后会因 “would be clobbered”
  # 整体失败，导致 config.lua 和 Caelestia autostart 都不落地。
  # 声明 force 让 HM 明确拥有这两个入口文件，覆盖自动生成的占位配置。
  xdg.configFile."hypr/hyprland.lua".force = true;
  xdg.configFile."hypr/config.lua".force = true;

  # 截图：hyprland.lua 里 Mod+Shift+S（区域）/ Mod+Shift+Alt+S（窗口）绑定
  programs.hyprshot = {
    enable = true;
    saveLocation = "$HOME/Pictures/Screenshots";
  };

  # 认证弹窗代理（hyprland 分支同款；polkit 本体在 system/security.nix）
  systemd.user.services.hyprpolkitagent = {
    Unit = {
      Description = "Hyprland Polkit Authentication Agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
