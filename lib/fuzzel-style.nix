# 由调色板生成的 fuzzel 公共配置（接替原 wmenu-style 的角色）。
# 紫色 accent-2 做交互焦点（边框/选中/匹配），与窗口聚焦的蓝色区分开。
# fuzzel 的颜色格式是 RRGGBBAA，这里统一补全不透明 alpha。
{ lib, theme }:
let
  hex = c: lib.removePrefix "#" c + "ff";
in
{
  main = {
    font = "${theme.font}:size=${toString theme.font-size-bar}";
    terminal = "ghostty -e"; # Terminal=true 的桌面项用它打开
    prompt = "❯ ";           # 与 sysmenu/fzf 的提示符一致
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
