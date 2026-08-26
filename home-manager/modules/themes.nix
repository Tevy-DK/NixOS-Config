# ./modules/themes.nix
{ pkgs, ... }:

{
  # 1. 声明底层光标（完美解决 Hyprland 环境下 Wayland 与 XWayland 光标不一致的顽疾）
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    enable = true;
    name = "Bibata-Modern-Ice"; # 可选变体: Bibata-Modern-Ice (冰白), Bibata-Modern-Classic (经典黑), Bibata-Modern-Amber (琥珀黄)
    size = 24;
    
    # 让 Home-Manager 自动把这个光标注入到 GTK 和 X11 核心配置中
    gtk.enable = true;
    x11.enable = true;
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk3"; # 让 Qt 尽量使用 GTK 的设置[reference:8]
    # 如果需要，可以显式设置风格
    # style.name = "adwaita-dark";
  };
  gtk = {
    enable = true;

    # 设置图标主题
    iconTheme = {
      name = "Tela";              # 主题名称[reference:1][reference:2]
      package = pkgs.tela-icon-theme;  # 主题所在的 Nix 包[reference:3][reference:4]
    };
  };
  xdg.configFile."gtk-4.0/gtk.css".text = ''
    window.ghostty {
        background-color: transparent;
    }
  '';
}
