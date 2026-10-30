# --- swayimg ---
# 简约 Wayland 图片查看器：无客户端边框、默认隐藏信息层，
# 背景/文字颜色跟随全局主题；按 t 可临时显示文件名和缩放信息。
# 图片的 XDG 默认关联见 home/xdg.nix。
{
  lib,
  pkgs,
  theme,
  ...
}:

let
  # theme 里的颜色是 #RRGGBB；swayimg/Lua 需要 AARRGGBB。
  argb = color: "0xff${lib.removePrefix "#" color}";
  argbAlpha = alpha: color: "0x${alpha}${lib.removePrefix "#" color}";
in
{
  home.packages = [ pkgs.swayimg ];

  xdg.configFile."swayimg/init.lua".text = ''
    -- Minimal viewer configuration.
    swayimg.mode = "viewer"
    swayimg.antialiasing = true
    swayimg.exif_orientation = true
    swayimg.decoration = false           -- no title bar / client-side border

    -- Hidden by default; press `t` to toggle.
    swayimg.text.visible = false
    swayimg.text.font = "${theme.font}"
    swayimg.text.size = ${toString theme.font-size-bar}
    swayimg.text.color = ${argb theme.fg}
    swayimg.text.background = ${argbAlpha "cc" theme.black}
    swayimg.text.shadow = 0x00000000     -- flat text, no shadow
    swayimg.text.timeout = 3
    swayimg.text.status_timeout = 2

    -- Only the essentials in the info layer.
    swayimg.viewer.text = {
      topleft = { "{name}" },
      bottomright = { "{list.index}/{list.total}  {scale}" },
    }

    swayimg.viewer.default_scale = "optimal"
    swayimg.viewer.default_position = "center"
    swayimg.viewer.autopos = "center"
    swayimg.viewer.loop = true
    swayimg.imagelist.adjacent = true

    swayimg.viewer.set_window_background(${argb theme.black})
    swayimg.viewer.set_image_background(${argb theme.black})
  '';
}
