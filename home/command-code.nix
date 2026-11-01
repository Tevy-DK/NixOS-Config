# Command Code 桌面客户端（Electron）。
# 上游只发布 x86_64 .deb，包由 Tevy-DK-attic 重打包，版本与哈希在该 flake 维护。
{ lib, pkgs, inputs, ... }:
{
  # 上游没有 Linux arm64 资产；其他架构上保持开关可加载但不安装。
  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
    inputs.tevy-dk-attic.packages.${pkgs.stdenv.hostPlatform.system}.command-code
  ];
}
