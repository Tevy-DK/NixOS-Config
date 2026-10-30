# --- mpv ---
# 简约播放器：无 OSD 进度条，底部 slim OSC 自动隐藏，颜色跟随全局主题。
# 视频/音频的 XDG 默认关联见 home/xdg.nix。
{ theme, ... }:
{
  programs.mpv = {
    enable = true;

    defaultProfiles = [ "gpu-hq" ];

    config = {
      vo = "gpu-next";
      hwdec = "auto-safe";

      osc = true;
      "osd-level" = 1;
      "osd-bar" = false;
      "osd-on-seek" = "msg";
      "osd-duration" = 1200;
      "osd-back-color" = "#00000000";
      "osd-shadow-offset" = 0;

      "sub-auto" = "fuzzy";
      "sub-font" = theme.font;
      "sub-font-size" = 40;
      "sub-color" = theme.fg;
      "sub-outline-color" = theme.black;
      "sub-outline-size" = 2;
      "sub-shadow-offset" = 0;

      "osd-font" = theme.font;
      "osd-font-size" = 30;
      "osd-color" = theme.fg;
      "osd-outline-color" = theme.black;
      "osd-outline-size" = 1.5;

      "save-position-on-quit" = true;
      "screenshot-format" = "png";
    };

    scriptOpts.osc = {
      layout = "slimbottombar";
      visibility = "auto";
      hidetimeout = 800;
      fadeduration = 150;
      deadzonesize = 0.3;
      minmousemove = 2;
      seekbarstyle = "bar";
      timetotal = true;
      title = "\${media-title}";
      windowcontrols = "no";

      boxalpha = 120;
      background_color = theme.bg;
      timecode_color = theme.fg;
      title_color = theme.fg;
      buttons_color = theme.fg;
      top_buttons_color = theme.fg;
      small_buttonsL_color = theme.fg;
      small_buttonsR_color = theme.fg;
      held_element_color = theme.accent;
      time_pos_color = theme.accent-bright;
      time_pos_outline_color = theme.black;
    };
  };
}
