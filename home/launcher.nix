# --- launcher ---
# 主题化启动器：fuzzel，只随 niri 工作环境安装（Mod+Space 调起），
# 配色由 lib/fuzzel-style.nix 从调色板生成。
# hyprland 娱乐环境不装（flake.nix 的 hyprland 档案把 launcher 覆盖为 false），
# 它用 caelestia 自带启动器。
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
