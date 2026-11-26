{ pkgs, config, inputs, ... }:
{
  home.packages = with pkgs; [
    #termusic
    google-chrome
    tela-icon-theme
    obs-studio
    marktext
    qq
    wechat
    nautilus
    nautilus-python
    uv
    # Zig 编辑器支持（VS Code 的 ziglang 扩展用，见 home/vscode-fhs.nix）：
    # zls 运行期要调用 zig（zig env 定位标准库），两个必须一起装
    zig
    zls
    # 自建 flake：SJMCL 启动器（Tevy-DK-attic，home-manager 用户级安装）
    inputs.tevy-dk-attic.packages.${pkgs.stdenv.hostPlatform.system}.sjmcl
    # 自建 flake：Motrix 下载器与 balenaEtcher 镜像写入工具
    inputs.tevy-dk-attic.packages.${pkgs.stdenv.hostPlatform.system}.motrix
    inputs.tevy-dk-attic.packages.${pkgs.stdenv.hostPlatform.system}.etcher
    # 自建 flake: omp
    inputs.tevy-dk-attic.packages.${pkgs.stdenv.hostPlatform.system}.omp
  ];
}
