{ lib, pkgs, config, ... }:

let
  chrome = "google-chrome.desktop";

  # Yazi 是终端文件管理器；上游 yazi.desktop 是 Terminal=true，niri/portal
  # 找不到终端启动器时不会打开。这里提供一个显式在 Ghostty 里运行的入口，
  # 同时保留 yazi 的 MIME 关联。
  yaziFileManager = "yazi-file-manager";
  yaziDesktop = "${yaziFileManager}.desktop";
  ghostty = config.programs.ghostty.package;
  yazi = config.programs.yazi.package;

  mpvDesktop = "mpv.desktop";
  swayimgDesktop = "swayimg.desktop";

  # 常见媒体类型；mpv / swayimg 的实际支持范围更大，这里只列文件管理器
  # 最常遇到的类型，避免把浏览器等无关 MIME 全部改写。
  videoMimes = [ "video/mp4" "video/webm" "video/ogg" "video/x-matroska"
                 "video/quicktime" "video/x-msvideo" "video/x-flv" "video/mpeg"
                 "video/3gpp" "video/x-ms-wmv" ];
  audioMimes = [ "audio/mpeg" "audio/ogg" "audio/wav" "audio/webm"
                 "audio/x-m4a" "audio/mp4" "audio/aac" "audio/opus"
                 "audio/mod" "audio/flac" "audio/x-flac" ];
  imageMimes = [ "image/avif" "image/bmp" "image/gif" "image/heic" "image/heif"
                 "image/jpeg" "image/jpg" "image/jxl" "image/png"
                 "image/svg+xml" "image/tiff" "image/webp" "image/x-icon"
                 "image/x-exr" ];
in
{
  xdg = {
    mime.enable = true;

    desktopEntries.${yaziFileManager} = {
      name = "Yazi";
      comment = "Terminal file manager in Ghostty";
      exec = "${lib.getExe ghostty} -e ${lib.getExe yazi} %f";
      terminal = false;
      mimeType = [ "inode/directory" ];
      categories = [ "System" "FileManager" ];
    };

    # 上游 swayimg.desktop 带 NoDisplay=true，这里覆盖成可见入口，
    # 否则 “打开方式” 里看不到它。
    desktopEntries.swayimg = {
      name = "Swayimg";
      genericName = "Image viewer";
      comment = "Minimal Wayland image viewer";
      exec = "${lib.getExe pkgs.swayimg} %F";
      icon = "swayimg";
      terminal = false;
      mimeType = imageMimes;
      categories = [ "Graphics" "Viewer" ];
    };

    mimeApps = {
      enable = true;

      defaultApplications =
        # 媒体 → 独立播放器（视频/音频 mpv，图片 swayimg）
        (lib.genAttrs (videoMimes ++ audioMimes) (_: mpvDesktop))
        // (lib.genAttrs imageMimes (_: swayimgDesktop))
        // {
          # 默认文件管理器 → Yazi（在 Ghostty 中打开）
          "inode/directory" = yaziDesktop;
          "text/html" = chrome;
          "x-scheme-handler/http" = chrome;
          "x-scheme-handler/https" = chrome;
          "x-scheme-handler/about" = chrome;
          "x-scheme-handler/unknown" = chrome;
        };
    };
  };
}
