# --- cursor ---
# 借鉴 koru：把 Bibata Modern 光标按全局主题重着色 —— 深色填充 + 主题蓝描边。
# derivation 在 lib/cursor-package.nix，系统层登录页（system/greeter.nix）共用
# 同一份，登录页和会话里的光标一致。
# 与 config.kdl 的 cursor 块同名（Bibata-Modern-DK），GTK 侧由 home.pointerCursor 注入。
{ pkgs, theme, ... }:
{
  # 会话里唯一的光标定义：home-manager 由此派生 GTK 光标（gtk.enable），
  # 并导出 XCURSOR_THEME/-SIZE；niri 通过 config.kdl 的 cursor 块读取同名主题。
  home.pointerCursor = {
    enable = true;
    name = theme.cursor-name;
    package = import ../lib/cursor-package.nix { inherit pkgs theme; };
    size = theme.cursor-size;
    gtk.enable = true;
  };
}
