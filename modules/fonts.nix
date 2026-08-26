{ config, pkgs, ...}:
{
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
        
    # 引入带图标的 Fira Code Nerd Font
    nerd-fonts.fira-code           
  ];

  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans CJK SC" ];
    serif     = [ "Noto Serif CJK SC" ];
    # 对应的字体名称通常为 "FiraCode Nerd Font"
    monospace = [ "FiraCode Nerd Font" "Noto Sans CJK SC" ]; 
    emoji     = [ "Noto Color Emoji" ];
  };
}