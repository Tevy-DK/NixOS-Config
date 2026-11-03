# --- cursor ---
# 固定原版 Bibata Modern Ice（nixpkgs 的 bibata-cursors），不做重着色，
# 也不随 Noctalia 深浅色切换。
#
# home.pointerCursor 负责安装光标包、导出 XCURSOR_THEME/-SIZE，并在
# gtk.enable 下把光标名/尺寸写进 gtk-{3,4}.0/settings.ini 与 dconf。
{ pkgs, theme, ... }:
{
  home.pointerCursor = {
    enable = true;
    name = theme.cursor-name;
    package = pkgs.bibata-cursors;
    size = theme.cursor-size;
    gtk.enable = true;
  };
}
