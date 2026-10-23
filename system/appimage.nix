{ pkgs, lib, ... }:

let
  # ── GStreamer 在 FHS 环境中的插件搜索路径 ──
  gstreamerPluginPath = lib.concatStringsSep ":" [
    "/usr/lib64/gstreamer-1.0"
    "/usr/lib/gstreamer-1.0"
    "/usr/lib32/gstreamer-1.0"
  ];

  # ── 自制的 appimage-run：补库 + 注入环境变量 ──
  appimage-run-fixed = pkgs.appimage-run.override {
    extraPkgs = p: with p; [
      # ① 修复 libfribidi.so.0 缺失
      fribidi
      # ② 提供系统 wayland 库（用于 LD_PRELOAD）
      wayland
      # ③ GStreamer 核心与常用插件（修复 appsink not found）
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
    ];
  };
in
{
  programs.appimage = {
    enable = true;
    binfmt = true;

    # 用 makeWrapper 给 appimage-run 本身加一层 wrapper，
    # 在它启动 AppImage 之前就设置好环境变量。
    package = pkgs.symlinkJoin {
      name = "appimage-run-fixed";
      paths = [ appimage-run-fixed ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/appimage-run \
          --prefix LD_PRELOAD : "${pkgs.wayland}/lib/libwayland-client.so.0" \
          --set GST_PLUGIN_SYSTEM_PATH_1_0 "${gstreamerPluginPath}" \
          --set GST_PLUGIN_SCANNER "${appimage-run-fixed}/libexec/gstreamer-1.0/gst-plugin-scanner"
      '';
    };
  };
}
