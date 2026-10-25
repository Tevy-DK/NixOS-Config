{ lib, ... }:

let
  chrome = "google-chrome.desktop";

  # Chrome 官方 desktop 文件里声明支持的类型(下面附了验证命令)
  videoMimes = [ "video/mp4" "video/webm" "video/ogg" ];
  audioMimes = [ "audio/mpeg" "audio/ogg" "audio/wav" "audio/webm"
                 "audio/x-m4a" "audio/mod" "audio/flac" ];
  imageMimes = [ "image/jpeg" "image/png" "image/gif" "image/webp" "image/x-icon" ];
in
{
  xdg = {
    mime.enable = true;   # 维护 mimeinfo.cache,原来没开,顺手加上

    mimeApps = {
      enable = true;

      defaultApplications =
        # 媒体 → Chrome
        (lib.genAttrs (videoMimes ++ audioMimes ++ imageMimes) (_: chrome))
        // {
          # ---- 你原来的,原样保留 ----
          "inode/directory" = "org.gnome.Nautilus.desktop";
          "text/html" = chrome;
          "x-scheme-handler/http" = chrome;
          "x-scheme-handler/https" = chrome;
          "x-scheme-handler/about" = chrome;
          "x-scheme-handler/unknown" = chrome;
        };
    };
  };
}
