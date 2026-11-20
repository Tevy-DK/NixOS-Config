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

  # niri 档案删除：Caelestia 运行时产物。不删 scheme.json / wallpaper /
  # sequences.txt：它们是 Hyprland 的用户状态，niri 不读，删了会丢方案。
  caelestiaArtifacts = [
    (cfg "hypr/scheme/current.conf")
    (cfg "hypr/scheme/current.lua")
    (cfg "qtengine/caelestia.colors")
    (cfg "qtengine/config.json")
    (cfg "btop/themes/caelestia.theme")
    (cfg "cava/themes/caelestia")
    (cfg "ghostty/themes/caelestia")
    (cfg "htop/htoprc")
    (cfg "fuzzel/fuzzel.ini")
    (cfg "nvtop/nvtop.colors")
    (cfg "spicetify/Themes/caelestia/color.ini")
    (cfg "Equicord/themes/caelestia.theme.css")
    (cfg "Vencord/themes/caelestia.theme.css")
    (cfg "BetterDiscord/themes/caelestia.theme.css")
    (cfg "equibop/themes/caelestia.theme.css")
    (cfg "vesktop/themes/caelestia.theme.css")
    (cfg "legcord/themes/caelestia.theme.css")
    (cfg "zed/themes/caelestia.json")
    (cfg "gtk-3.0/thunar.css")
    (cfg "gtk-4.0/thunar.css")
    # 已关闭的生产者（enablePandora/enableWarp = false）留下的旧残留。
    (data "PandoraLauncher/themes/caelestia.json")
    (data "warp-terminal/themes/caelestia.yaml")
  ];
}
