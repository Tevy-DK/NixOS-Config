{ config, pkgs, ...}:
{
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji

    # 官方 Cascadia Code 发行包，内含 "Cascadia Code NF"（Nerd 补丁变体，
    # 带 powerline/devicon 等图标，家族名见 fc-scan）
    cascadia-code
    # 仅 VSCodium 的编辑器/终端继续使用 Fira Code，保留安装
    nerd-fonts.fira-code
  ];

  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans CJK SC" ];
    serif     = [ "Noto Serif CJK SC" ];
    # 默认等宽字体（终端 / 界面）：Cascadia Code 的 Nerd 补丁变体
    monospace = [ "Cascadia Code NF" "Noto Sans CJK SC" ];
    emoji     = [ "Noto Color Emoji" ];
  };
}