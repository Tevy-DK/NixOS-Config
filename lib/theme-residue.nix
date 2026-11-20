{ configHome, dataHome }:
let
  cfg = p: "${configHome}/${p}";
  data = p: "${dataHome}/${p}";
in {
  # Hyprland 档案删除：Noctalia 运行时产物。
  # gtk.css 不在这里：它在 Hyprland 档案里只应删掉 niri 的 import/软链，
  # 由 home/hyprland-theme.nix 的定向清理处理，避免误删可用的 Caelestia 文件。
  noctaliaArtifacts = [
    (cfg "gtk-3.0/noctalia.css")
    (cfg "gtk-3.0/noctalia-extensions.css")
    (cfg "gtk-4.0/noctalia.css")
    (cfg "gtk-4.0/noctalia-extensions.css")
    (cfg "qt5ct/colors/noctalia.conf")
    (cfg "qt6ct/colors/noctalia.conf")
    (cfg "btop/themes/noctalia.theme")
    (cfg "cava/themes/noctalia")
    (cfg "ghostty/themes/noctalia")
    (cfg "niri/noctalia.kdl")
  ];

  # Caelestia 在 Hyprland 上主动产出、niri 必须删除的文件。
  # 不含 scheme.json / wallpaper / sequences.txt：那是用户状态，删了会丢方案。
  caelestiaRuntimeArtifacts = [
    (cfg "hypr/scheme/current.conf")
    (cfg "hypr/scheme/current.lua")
    (cfg "btop/themes/caelestia.theme")
    (cfg "cava/themes/caelestia")
    (cfg "ghostty/themes/caelestia")
    (cfg "gtk-3.0/thunar.css")
    (cfg "gtk-4.0/thunar.css")
  ];

  # cli.json 里已关闭的生产者留下的产物：两个档案都要删
  # （Hyprland 上 Caelestia 不再重写它们，留着就是跨档案残留）。
  caelestiaDisabledArtifacts = [
    (cfg "htop/htoprc")
    (cfg "fuzzel/fuzzel.ini")
    (cfg "nvtop/nvtop.colors")
    (cfg "qtengine/caelestia.colors")
    (cfg "qtengine/config.json")
    (cfg "spicetify/Themes/caelestia/color.ini")
    (cfg "Equicord/themes/caelestia.theme.css")
    (cfg "Vencord/themes/caelestia.theme.css")
    (cfg "BetterDiscord/themes/caelestia.theme.css")
    (cfg "equibop/themes/caelestia.theme.css")
    (cfg "vesktop/themes/caelestia.theme.css")
    (cfg "legcord/themes/caelestia.theme.css")
    (cfg "zed/themes/caelestia.json")
    (data "PandoraLauncher/themes/caelestia.json")
    (data "warp-terminal/themes/caelestia.yaml")
  ];

  # 旧代 HM/Noctalia 留下的文件，ghostty 不读（生效的是 config）。
  legacyThemeArtifacts = [
    (cfg "ghostty/config.ghostty")
  ];
}
