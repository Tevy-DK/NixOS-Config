# --- launcher ---
# 主题化启动器：fuzzel（niri 里 Mod+Space 调起），配色由 lib/fuzzel-style.nix 从调色板生成。
# 保留 launcher 包装脚本名，niri / hyprland 的按键绑定不用动。
{ lib, pkgs, theme, ... }:
let
  fuzzel-style = import ../lib/fuzzel-style.nix { inherit lib theme; };
in
{
  programs.fuzzel = {
    enable = true;
    settings = fuzzel-style;
  };

  home.packages = [
    (pkgs.writeShellScriptBin "launcher" ''
      exec ${pkgs.fuzzel}/bin/fuzzel
    '')
  ];
}
