# omp = oh-my-pi：pi 编码代理的配置/技能套件（上游包名就是 omp）。
# 包来自 numtide/llm-agents.nix（flake input → shared-nixpkgs overlay →
# pkgs.llm-agents 命名空间），用本仓 nixpkgs 构建。
{ pkgs, ... }:
{
  home.packages = with pkgs.llm-agents; [
    omp
  ];
}
