# --- caelestia-shell 用户层（恢复自 hyprland 分支）---
# Hyprland 桌面的状态栏/启动器/通知中心（quickshell 全家桶），
# 只在 desktop = "hyprland" 的机器上随 home/hyprland.nix 一起启用。
# 包直接取 nixpkgs 的 caelestia-shell / caelestia-cli，不再引上游 flake。
# shell.json 整份来自 ./shell.json；cli.json 选择性开启：Caelestia 是壁纸
# 调色板源，只把颜色分发给它有模板的消费方（hypr/GTK/终端/btop），cava/
# fuzzel 等由 lib/caelestia-apps.nix 的 postHook 写入主题文件，不覆盖 HM 配置。
#
# GTK 外观：与 niri 的 gtk.nix 互斥（flake.nix 档案开关）。这里只声明
# 与 niri 同一套的静态 dconf 基础键（adw-gtk3-dark/字体/图标），不加载
# niri 的 Noctalia 模板/hook。Caelestia 的 enableGtk 会按壁纸重写 gtk.css，
# 与“用 theme.nix 固定配色”的目标冲突，因此关闭；GTK 颜色保持 adw-gtk3-dark。
# 切换代际时 HM 不会清除旧 dconf 键，显式同写后两个环境的 GTK 基础设置一致。
{ pkgs, lib, theme, ... }:
let
  caelestiaApps = import ../lib/caelestia-apps.nix { inherit pkgs theme; };
in
{
  # 不生成 caelestia-shell systemd 用户单元，改由 Hyprland 启动时直接拉起
  #（caelestia shell -d，见 home/hyprland.lua 的 AUTOSTART）
  home.packages = [
    pkgs.caelestia-shell
    pkgs.caelestia-cli
  ];

  xdg.configFile = {
    "caelestia/shell.json".text =
      builtins.toJSON (builtins.fromJSON (builtins.readFile ./shell.json));
    "caelestia/cli.json".text = builtins.toJSON {
      theme = {
        enableHypr = true;      # ~/.config/hypr/scheme/current.lua
        enableGtk = true;       # gtk.css + thunar.css + dconf
        enableTerm = true;      # 运行中终端的 OSC 10/11/12/4
        enableBtop = true;      # btop/themes/caelestia.theme
        enableCava = false;     # 会整份覆盖 HM 的 cava/config，交给 postHook
        enableQt = false;       # qtengine 未安装
        enableHtop = false;
        enableFuzzel = false;
        enableNvtop = false;
        enableDiscord = false;
        enableSpicetify = false;
        enablePandora = false;
        enableWarp = false;
        enableChromium = false;
        enableZed = false;
        iconTheme = "Tela";     # 否则 apply_gtk 会把图标改成 Papirus
        postHook = "${lib.getExe caelestiaApps} --hook";
      };
    };
    # 与 niri 的 gtk.nix 同款：旧代际/手工改过的 settings.ini 是普通文件时，
    # 不加 force 会让 HM 的 checkLinkTargets 以 “would be clobbered” 整体失败。
    "gtk-3.0/settings.ini".force = true;
    "gtk-4.0/settings.ini".force = true;
  };

  # 激活时按 scheme.json 分发配色；文件缺失则用 theme-hyprland.nix 深色兜底。
  home.activation.caelestiaAppsApply = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
    ${lib.getExe caelestiaApps} --apply || echo "caelestia-apps: apply failed" >&2
  '';

  gtk = {
    enable = true;
    colorScheme = "dark";
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    font = {
      name = theme.font;
      size = theme.font-size-ui;
    };
    iconTheme = {
      name = "Tela";
      package = pkgs.tela-icon-theme;
    };
  };
}
