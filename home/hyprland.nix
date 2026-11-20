# --- Hyprland 用户层（恢复自 hyprland-recovery 分支）---
# 主程序与 portal 由系统层 system/hyprland.nix 安装（package = null），
# 这里只负责配置：hyprland.lua（Lua 版配置）+ 截图 + 认证代理。
{ config, pkgs, inputs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;          # ⚠️ 必须保留 true，否则不会生成你的配置文件！

    package = null;         # ✅ 告诉 HM 不要自己安装 Hyprland，用系统的
    portalPackage = null;   # ✅ 告诉 HM 不要自己安装 Portal，用系统的
    plugins = [ ];
    extraLuaFiles = {
      "config" = {
        content = ./hyprland.lua;
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
