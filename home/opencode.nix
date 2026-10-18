# OpenCode 2 + OmO（AI 编程代理）
#
# 包来自 numtide/llm-agents.nix（flake input → shared-nixpkgs overlay →
# pkgs.llm-agents 命名空间），用本仓 nixpkgs 构建：
#   - opencode2-desktop  OpenCode 2 桌面客户端（上游 .deb 二进制，MIT）
#   - oh-my-opencode     OmO 多模型编排器（unfree，靠全局 allowUnfree 放行；
#                        上游已由 opencode 插件改名为独立 TUI oh-my-openagent，
#                        命令 omo，配置 ~/.omo/omo.jsonc，首次用 `omo setup` 迁移）
{ pkgs, ... }:
{
  home.packages = with pkgs.llm-agents; [
    opencode2-desktop
    oh-my-opencode
  ];
}
