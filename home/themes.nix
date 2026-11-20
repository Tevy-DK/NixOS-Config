# ./home/themes.nix
# 主题归属：Qt 平台主题（写入者：本模块；颜色跟随 GTK，niri 下由 Noctalia
#   qt 模板生成 qt{5,6}ct/colors，Hyprland 下 enableQt = false 不写颜色）。
# 光标固定在 home/cursor-theme.nix（原版 Bibata Modern Ice，无模式切换），
# GTK 外观已移交 home/gtk.nix + Noctalia 的 gtk3/gtk4 模板。
# 这里只保留 Qt 平台主题：gtk3 路线让 Qt 应用跟随 GTK 设置（adw-gtk3 由
# Noctalia 模板按模式选择，CSS 由 noctalia.css 注入）——Qt 颜色间接跟壁纸走；
# noctalia 的 qt 模板写出的 qt{5,6}ct/colors/noctalia.conf 备用不冲突。
{ pkgs, ... }:
{
  qt = {
    enable = true;
    platformTheme.name = "gtk3"; # 让 Qt 尽量使用 GTK 的设置
  };
}
