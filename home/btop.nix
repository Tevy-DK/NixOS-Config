# --- btop ---
# 配色由 Noctalia 内置 btop 模板生成到
#   $XDG_CONFIG_HOME/btop/themes/noctalia.theme
# 这里只声明使用哪个主题；Noctalia 的 apply.sh 检测到 color_theme 已经是
# "noctalia" 就不会再改 HM 管理的 btop.conf（只读 store 软链）。
# themes 不再在这里声明：noctalia.theme 归 Noctalia 运行时所有。
{ ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "noctalia";
      theme_background = false;
      truecolor = true;
      rounded_corners = true;
      graph_symbol = "braille";
      update_ms = 2000;
    };
  };
}
