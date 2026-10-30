# --- cava ---
# cava-config 已声明 [color] theme = "noctalia"；主题文件
#   $XDG_CONFIG_HOME/cava/themes/noctalia
# 由 Noctalia 内置 cava 模板运行时生成，HM 不管理它。
{ ... }:
{
  programs.cava.enable = true;
  xdg.configFile."cava/config".source = ./cava-config;
}
