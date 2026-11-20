# --- caelestia-shell 用户层（恢复自 hyprland 分支）---
# Hyprland 桌面的状态栏/启动器/通知中心（quickshell 全家桶），
# 只在 desktop = "hyprland" 的机器上随 home/hyprland.nix 一起启用。
# 包直接取 nixpkgs 的 caelestia-shell / caelestia-cli，不再引上游 flake。
# 配置仍整份来自 ./shell.json；cli.json 只关掉按壁纸改写 GTK。
#
# GTK 外观：与 niri 的 gtk.nix 互斥（flake.nix 档案开关）。这里只声明
# 与 niri 同一套的静态 dconf 基础键（adw-gtk3-dark/字体/图标），不加载
# niri 的 Noctalia 模板/hook。Caelestia 的 enableGtk 会按壁纸重写 gtk.css，
# 与“用 theme.nix 固定配色”的目标冲突，因此关闭；GTK 颜色保持 adw-gtk3-dark。
# 切换代际时 HM 不会清除旧 dconf 键，显式同写后两个环境的 GTK 基础设置一致。
{ pkgs, theme, ... }:
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
      theme.enableGtk = false;
    };
  };

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
