# --- caelestia-shell 用户层（恢复自 hyprland 分支）---
# Hyprland 桌面的状态栏/启动器/通知中心（quickshell 全家桶），
# 只在 desktop = "hyprland" 的机器上随 home/hyprland.nix 一起启用。
# 包直接取 nixpkgs 的 caelestia-shell / caelestia-cli，不再引上游 flake。
# shell.json 整份来自 ./shell.json；cli.json 选择性开启：Caelestia 是壁纸
# 调色板源，只把颜色分发给它有模板的消费方（hypr/GTK/终端/btop），cava/
# fuzzel 等由 lib/caelestia-apps.nix 的 postHook 写入主题文件，不覆盖 HM 配置。
#
# GTK 外观：与 niri 的 gtk.nix 互斥（flake.nix 档案开关）。gtk.css/thunar.css
# 与 dconf 的 GTK 键由 Caelestia 的 apply_gtk 写；主题名按 mode 由
# caelestia-apps 的 postHook 纠正（apply_gtk 写死 adw-gtk3-dark）。HM 只写
# 字体/图标与 settings.ini（force），不声明 gtk.css，也不写主题名/模式。
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
    # gtk.theme = null 后 HM 不再自动安装 adw-gtk3；Caelestia 写 dconf 的
    # 主题名指向它，必须留在 XDG_DATA_DIRS 里。
    pkgs.adw-gtk3
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

  # GTK 主题名/模式归 Caelestia：apply_gtk 写 gtk.css/thunar.css 和 dconf，
  # caelestia-apps 的 postHook 再按 mode 纠正写死的 adw-gtk3-dark。
  # HM 写 null，避免每次激活把 prefer-light 重置回固定值。
  gtk = {
    enable = true;
    theme = null;         # 主题名由 caelestia-apps 按 mode 写 dconf/settings.ini
    colorScheme = null;   # 同上，避免 HM 激活把 prefer-light 重置成 prefer-dark
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
