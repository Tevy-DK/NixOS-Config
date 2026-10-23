{ ... }:

{
  # 启用 appimage 支持（NixOS 24.05+ 推荐）
  programs.appimage = {
    enable = true;
    binfmt = true; # 注册 binfmt_misc，使 AppImage 可以直接执行
    
    # 关键：为 appimage-run 环境补充缺失的库
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: with pkgs; [
        fribidi  # 解决 libfribidi.so.0 缺失
        # 如果后续遇到其他库缺失，可以继续在这里添加
        # 例如：libepoxy, harfbuzz, libthai 等
      ];
    };
  };
}
