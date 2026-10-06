# 由调色板生成的 fuzzel 公共配置（接替原 wmenu-style 的角色）。
# 紫蓝 accent-2 做交互焦点（边框/选中/匹配），与窗口聚焦的亮蓝区分开。
# fuzzel 的颜色格式是 RRGGBBAA，这里统一补全不透明 alpha。
#
# 图标：fuzzel 不读 GTK/dconf 里的图标主题设置，icon-theme 默认值是字面量
# "default"（不存在的主题目录，实际回落 hicolor），所以必须在这里显式写
# "Tela" 才能用上 gtk.nix 装的 Tela 图标主题（名字大小写敏感）。
{ lib, theme }:
let
  hex = c: lib.removePrefix "#" c + "ff";
in
{
  main = {
    font = "${theme.font}:size=${toString theme.font-size-bar}";
    terminal = "ghostty -e"; # Terminal=true 的桌面项用它打开
    prompt = "❯ ";           # 与 sysmenu/fzf 的提示符一致
    icon-theme = "Tela";     # gtk.nix 的 iconTheme.name，见顶部说明
  };
  colors = {
    background = hex theme.bg;
    text = hex theme.fg;
    input = hex theme.fg;
    placeholder = hex theme.muted-alt;
    prompt = hex theme.accent-2;
    match = hex theme.accent-2;          # 命中的字符
    selection = hex theme.accent-2;      # 选中项背景
    selection-text = hex theme.bg;       # 选中项文字
    selection-match = hex theme.bg;      # 选中项里命中的字符
    border = hex theme.accent-2;
  };
}
