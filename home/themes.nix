# ./home/themes.nix
# 光标已移交 home/cursor-theme.nix（重着色 Bibata），GTK 已移交 home/gtk.nix；
# 这里只保留 Qt 平台主题与 Ghostty 的窗口透明 CSS。
{ pkgs, ... }:
{
  qt = {
    enable = true;
    platformTheme.name = "gtk3"; # 让 Qt 尽量使用 GTK 的设置
  };
}
