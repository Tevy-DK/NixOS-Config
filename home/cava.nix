# --- cava ---
# cava-config 已声明 [color] theme = "noctalia"；主题文件
#   $XDG_CONFIG_HOME/cava/themes/noctalia
# 由 Noctalia 内置 cava 模板运行时生成，HM 不管理它。
# Hyprland 档案把 theme 改成 caelestia（home/hyprland-theme.nix），主题文件
# 由 Caelestia 的 postHook 生成。
{ ... }:
{
  programs.cava.enable = true;
  # 旧会话里 Caelestia 曾整份覆盖成普通文件；force 让 HM 能收回软链。
  xdg.configFile."cava/config" = {
    source = ./cava-config;
    force = true;
  };
}
