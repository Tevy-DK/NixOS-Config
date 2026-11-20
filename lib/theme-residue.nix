{ configHome }:
let
  cfg = p: "${configHome}/${p}";
in {
  # Hyprland 档案删除：Noctalia 运行时产物。gtk.css 是 niri 的 import 文件，
  # 在 Hyprland 上由 Caelestia 重新生成，所以一并删除。
  noctaliaArtifacts = [
    (cfg "gtk-3.0/gtk.css")
    (cfg "gtk-4.0/gtk.css")
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
  ];
}
