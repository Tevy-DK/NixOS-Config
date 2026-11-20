# --- Hyprland 桌面外观（跟随 Caelestia 壁纸方案）---
# 主题归属：btop/cava/ghostty 主题选择（写入者：本模块；主题文件写入者：
#   Caelestia CLI 与 lib/caelestia-apps.nix 的 postHook）。
# Caelestia 是 Hyprland 的唯一调色板来源：它写
#   ~/.config/btop/themes/caelestia.theme
#   ~/.config/gtk-{3,4}.0/gtk.css
#   ~/.config/hypr/scheme/current.lua（Lua 配置）或 current.conf（其它情况，
#     包括没有 HYPRLAND_INSTANCE_SIGNATURE 的 HM 激活期重放）
# 并由 lib/caelestia-apps.nix 的 postHook 写
#   ~/.config/ghostty/themes/caelestia
#   ~/.config/cava/themes/caelestia
# 这里只声明“用哪个主题”，不生成主题文件；niri 档案不加载本模块。
{ config, lib, ... }:
let
  residue = import ../lib/theme-residue.nix {
    inherit (config.xdg) configHome dataHome;
  };
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

  # 共享 HOME 下 niri 写入的 Noctalia 产物对 Hyprland 是污染：noctalia.css、
  # noctalia.theme 等。每次激活先清掉；gtk.css 只删 niri 的 import/软链，
  # 不误删 Caelestia 已经生成的可用文件（重放随后会重建它）。
  home.activation.themeResidueCleanupHyprland =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      rm -f -- ${lib.escapeShellArgs residue.noctaliaArtifacts}
      for v in 3 4; do
        f="$HOME/.config/gtk-$v.0/gtk.css"
        if [ -L "$f" ] || grep -q 'noctalia.css' "$f" 2>/dev/null; then
          rm -f -- "$f"
        fi
      done
    '';
}
