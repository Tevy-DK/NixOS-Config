{ lib, pkgs, config, ... }:

let
  chrome = "google-chrome.desktop";

  # Yazi 是终端文件管理器；上游 yazi.desktop 是 Terminal=true，xdg-open 的
  # 通用启动路径不会替它找终端，直接执行 `yazi %f` 会失败。这里提供一个显式
  # 在 Ghostty 里运行的入口并设为 inode/directory 默认；入口 noDisplay，菜单
  # 里只保留上游条目，避免出现两个 Yazi。
  yaziFileManager = "yazi-file-manager";
  yaziDesktop = "${yaziFileManager}.desktop";
  ghostty = config.programs.ghostty.package;
  yazi = config.programs.yazi.package;

  mpvDesktop = "mpv.desktop";
  swayimgDesktop = "swayimg.desktop";
  nautilusDesktop = "org.gnome.Nautilus.desktop";

  # Nautilus 通过 gnome-autoar 直接浏览压缩包内容；这里取它 desktop
  # 条目声明的 MIME 集合（zip/7z/rar/tar.*/gz/xz/bz2/zstd 等），保证
  # 关联到的类型都确实能打开，而不是落到 SJMCL 之类的应用。
  archiveMimes = [ "application/zip" "application/gzip" "application/bzip2"
                   "application/zstd" "application/x-7z-compressed"
                   "application/x-7z-compressed-tar" "application/x-bzip"
                   "application/x-bzip-compressed-tar"
                   "application/x-bzip2-compressed-tar" "application/x-compress"
                   "application/x-compressed-tar" "application/x-cpio"
                   "application/x-gzip" "application/x-lha" "application/x-lzip"
                   "application/x-lzip-compressed-tar" "application/x-lzma"
                   "application/x-lzma-compressed-tar" "application/x-tar"
                   "application/x-tarz" "application/x-xar" "application/x-xz"
                   "application/x-xz-compressed-tar"
                   "application/x-zstd-compressed-tar" "application/vnd.rar" ];

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
      noDisplay = true;
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
        # 压缩包 → Nautilus（gnome-autoar 内建浏览）
        // (lib.genAttrs archiveMimes (_: nautilusDesktop))
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
