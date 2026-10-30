{ config, pkgs, inputs, ... }:

{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    package = pkgs.yazi.override {
      _7zz = pkgs._7zz-rar;   # 支持 RAR 解压
    };
    plugins = {
      inherit (pkgs.yaziPlugins) mediainfo git mount recycle-bin;
    };
    extraPackages = with pkgs; [
      file
      imagemagick
      resvg
      ffmpeg
      mmtui
      glib                # gio open：走 GIO/mimeapps.list，和 Nautilus 同一套 XDG 解析
    ];

    # Yazi 默认只把图片/音视频/PDF 交给 xdg-open；text/*、代码和压缩包
    # 分别走 $EDITOR 和内置解压，完全不看 mimeapps.list。这里统一用
    # `gio open`（Nautilus 使用的同一后端），让所有普通文件都按 XDG
    # 默认应用打开；目录仍保留 Yazi 默认规则，不受影响。
    settings = {
      opener.xdg = [
        {
          run = "gio open %s1";
          desc = "Open (XDG)";
          orphan = true;
          for = "linux";
        }
      ];

      open = {
        prepend_rules = [
          { mime = "{audio,video}/*"; use = "xdg"; }
          { mime = "image/*"; use = "xdg"; }
          { mime = "text/*"; use = "xdg"; }
          { mime = "application/*"; use = "xdg"; }
          { mime = "inode/empty"; use = "xdg"; }
        ];
        # 未知 MIME 也回退到 XDG；目录规则在默认规则中先匹配，不会被它覆盖。
        append_rules = [
          { url = "*"; use = "xdg"; }
        ];
      };
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "M";                          # 按 m 键
          run = "plugin mount";              # 调用 mount 插件
          desc = "Mount / unmount device";   # 描述（在帮助中显示）
        }
      ];
    };
  };
}
