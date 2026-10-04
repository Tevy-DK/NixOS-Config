# 终端工作流（借鉴 koru）：fzf 模糊选择 + zoxide 跳目录 + bat/eza 可读输出。
# fzf 与 bat 的配色同样由全局 theme.nix 驱动。
{ config, pkgs, theme, ... }:
{
  programs.fzf = {
    enable = true;
    enableFishIntegration = true; # Ctrl-R 搜历史 / Ctrl-T 搜文件 / Alt-C 跳目录
    colors = {
      bg = theme.bg;
      "bg+" = theme.bg-alt;
      fg = theme.fg;
      "fg+" = theme.fg-bright;
      hl = theme.accent;
      "hl+" = theme.accent-bright;
      info = theme.muted-alt;
      prompt = theme.accent-2;
      pointer = theme.accent-2;
      marker = theme.accent-2;
      spinner = theme.accent-2;
      header = theme.muted;
      scrollbar = theme.muted-alt;
    };
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true; # z 命令替代 cd
  };
  programs.bat = {
    enable = true;
    # theme = "ansi"：直接复用终端的 16 ANSI 色（ghostty 已接 theme.nix 的 Koru Fern），
    # 同 koru 的做法，bat 配色自动跟随全局主题
    config.theme = "ansi";
  };
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish.shellAliases = {
    ll = "eza -la";
    lt = "eza --tree";
  };

  # man 页用 bat 着色（同 koru）
  programs.fish.interactiveShellInit = ''
    set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -x MANROFFOPT "-c"
  '';
}
