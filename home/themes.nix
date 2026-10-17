# ./home/themes.nix
# 光标已移交 home/cursor-theme.nix（重着色 Bibata），GTK 已移交 home/gtk.nix，
# Ghostty 的窗口透明 CSS 已随玻璃规则移入 niri（config.kdl）。
# 这里只保留 Qt 平台主题：gtk3 路线让 Qt 应用跟随 GTK 设置（adw-gtk3-dark +
# noctalia 模板写入的 gtk.css @import）——Qt 颜色间接跟壁纸走，noctalia 的
# qt 模板写出的 qt{5,6}ct/colors/noctalia.conf 备用不冲突。
{ pkgs, ... }:
{
  qt = {
    enable = true;
    platformTheme.name = "gtk3"; # 让 Qt 尽量使用 GTK 的设置
  };
}
