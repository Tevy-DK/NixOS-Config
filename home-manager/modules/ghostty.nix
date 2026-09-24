{ pkgs, ... }:

let
  # 1. 使用 fetchFromGitHub 声明式地获取着色器仓库
  cursorShaders = pkgs.fetchFromGitHub {
    owner = "sahaj-b";
    repo = "ghostty-cursor-shaders";
    rev = "0a274beac8b93ee6ce6b94402b7313a0417b8e38";
    hash = "sha256-B7B6K7Ee4uJlW8zzLP3ILgddnbcIQyNimY+rVllzbR0=";
  };
in {
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

    # 为常用 Shell 开启集成（推荐）
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    settings = {
      theme = "Catppuccin Mocha";              # 流行的现代暗色主题[reference:0][reference:1]
      window-theme = "auto";                   # 跟随系统主题

      background-opacity = 0.75;
      background-blur-radius = 24; 
      
      font-family = "FiraCode Nerd Font";             # 字体名称[reference:15]
      font-size = 12;                          # 字号[reference:16]
      font-thicken = true;                     # 略微加粗，提升可读性
      adjust-cell-height = 2;                  # 调整行高，更宽松

      cursor-style = "bar";                    # 细条光标，更现代
      cursor-style-blink = true;               # 允许闪烁
      cursor-opacity = 0.8;                    # 光标透明度

      mouse-hide-while-typing = true;          # 打字时自动隐藏鼠标
      copy-on-select = "clipboard";            # 选中即复制到系统剪贴板
      clipboard-paste-protection = true;       # 防止意外粘贴大量内容

      shell-integration = "detect";            # 自动检测并集成 Shell

      keybind = [
    	"ctrl+t=new_tab"
    	"ctrl+shift+left=previous_tab"
    	"ctrl+shift+right=next_tab"
    	"ctrl+w=close_surface"
    	"ctrl+d=new_split:right"
    	"ctrl+shift+d=new_split:down"
    	"ctrl+alt+h=goto_split:left"
    	"ctrl+alt+l=goto_split:right"
    	"ctrl+alt+k=goto_split:top"
    	"ctrl+alt+j=goto_split:bottom"
    	"ctrl+shift+e=equalize_splits"
    	"ctrl+shift+f=toggle_split_zoom"
    	"ctrl+plus=increase_font_size:1"
    	"ctrl+minus=decrease_font_size:1"
    	"ctrl+zero=reset_font_size"
    	"global:ctrl+grave_accent=toggle_quick_terminal"
    	"ctrl+shift+comma=reload_config"
      ];

      scrollback-limit = 25000000;              # 回滚行数限制 (约25MB)
      confirm-close-surface = false;	#关掉倒霉的提醒
      custom-shader = "${cursorShaders}/cursor_warp.glsl";
      custom-shader-animation = "always";    #光标特效
    };
  };
}
