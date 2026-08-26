{ config, pkgs, ... }:

{
  programs.yazi = {
    enable = true;

    # 为 Fish Shell 开启集成（如果你用的是其他 Shell，可以对应修改）
    enableFishIntegration = true;
    # enableBashIntegration = true;   # 如果用 Bash
    # enableZshIntegration = true;    # 如果用 Zsh

    # ==========================================
    # 核心：用支持 RAR 的 _7zz-rar 替换默认的 _7zz
    # ==========================================
    package = pkgs.yazi.override {
      _7zz = pkgs._7zz-rar;
    };

    # ==========================================
    # 插件管理
    # ==========================================
    plugins = {
      inherit (pkgs.yaziPlugins) mediainfo git mount;
    };
    # ==========================================
    # 外部依赖管理
    # ==========================================
    extraPackages = with pkgs; [
      # --- 核心依赖 ---
      file      # Yazi 自身的文件类型检测

      # --- 图片预览 ---
      imagemagick   # 预览字体、HEIC、JPEG XL 等格式
      resvg         # 预览 SVG 图片

      # --- 视频预览 ---
      ffmpeg        # 生成视频缩略图

      # --- 音频预览 ---
      # ffmpeg 同样可以处理音频文件的封面图

      # --- 压缩包预览（RAR 由 _7zz-rar 处理，这里保留基础支持）---
      # _7zz-rar 已经被替换到 package 中，这里无需额外添加
    ];
  };
}
