# omp = oh-my-pi：pi 编码代理的配置/技能套件（上游包名就是 omp）。
# 包来自自建 Tevy-DK-attic flake（只取上游 Release 二进制），
# 版本与哈希由该 flake 维护。
{ pkgs, inputs, ... }:
{
  home.packages = [
    inputs.tevy-dk-attic.packages.${pkgs.stdenv.hostPlatform.system}.omp
  ];
}
