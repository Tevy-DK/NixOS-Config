# --- Hyprland 桌面外观（跟随 Caelestia 壁纸方案）---
# Caelestia 是 Hyprland 的唯一调色板来源：它写
#   ~/.config/btop/themes/caelestia.theme
#   ~/.config/gtk-{3,4}.0/gtk.css
#   ~/.config/hypr/scheme/current.lua
# 并由 lib/caelestia-apps.nix 的 postHook 写
#   ~/.config/ghostty/themes/caelestia
#   ~/.config/cava/themes/caelestia
# 这里只声明“用哪个主题”，不生成主题文件；niri 档案不加载本模块。
{ config, lib, ... }:
let
  residue = import ../lib/theme-residue.nix { inherit (config.xdg) configHome; };
in
{
  # btop：主题文件归 Caelestia（enableBtop），HM 只选主题名。
  programs.btop.settings.color_theme = lib.mkForce "caelestia";

  # ghostty：主题文件归 caelestia-apps；其余窗口/键位/字体沿用共享模块。
  programs.ghostty.settings.theme = lib.mkForce "caelestia";

  # cava：主题文件归 caelestia-apps，主配置仍在 HM（home/cava.nix）。
  xdg.configFile."cava/config" = lib.mkForce {
    text = builtins.replaceStrings
      [ ''theme = "noctalia"'' ]
      [ ''theme = "caelestia"'' ]
      (builtins.readFile ./cava-config);
    force = true;
  };

  # HM 的 ghostty 配置在激活期用 +validate-config 校验，themes/caelestia 必须
  # 先存在；caelestia-apps 随后用真实主题原子覆盖它。
  home.activation.caelestiaGhosttyThemeBootstrap =
    lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      f="$HOME/.config/ghostty/themes/caelestia"
      if [ ! -e "$f" ]; then
        mkdir -p "$(dirname "$f")"
        printf '%s\n' '# Placeholder: caelestia-apps writes this.' > "$f"
      fi
    '';

  # 共享 HOME 下 niri 写入的 Noctalia 产物对 Hyprland 是污染：gtk.css 的
  # noctalia import、noctalia.theme 等。每次激活先清掉，保证本档案的
  # rg noctalia ~/.config/... 干净；Caelestia 随后生成自己的文件。
  home.activation.themeResidueCleanup = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    rm -f -- ${lib.escapeShellArgs residue.noctaliaArtifacts}
  '';
}
