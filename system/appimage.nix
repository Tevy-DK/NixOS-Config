{ pkgs, lib, ... }:

let
  # GStreamer 插件在 FHS 环境中的搜索路径
  gstreamerPluginPath = lib.concatStringsSep ":" [
    "/usr/lib64/gstreamer-1.0"
    "/usr/lib/gstreamer-1.0"
    "/usr/lib32/gstreamer-1.0"
  ];

  # 基础 appimage-run，补齐必要的库和 GStreamer 包
  appimageRun = pkgs.appimage-run.override {
    extraPkgs = p: with p; [
      fribidi
      wayland
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

    package = pkgs.symlinkJoin {
      name = "appimage-run-fixed";
      paths = [ appimageRun ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/appimage-run \
          --prefix LD_PRELOAD : "${pkgs.wayland}/lib/libwayland-client.so.0" \
          --set GST_PLUGIN_SYSTEM_PATH_1_0 "${gstreamerPluginPath}" \
          --set GST_PLUGIN_PATH_1_0 "${gstreamerPluginPath}" \
          --set GST_PLUGIN_SCANNER "${appimageRun}/libexec/gstreamer-1.0/gst-plugin-scanner" \
          --set WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS "1"
      '';
    };
  };
}
