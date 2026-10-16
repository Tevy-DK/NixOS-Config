{ pkgs, theme, ... }:

let
  # 使用 fetchFromGitHub 声明式地获取着色器仓库
  cursorShaders = pkgs.fetchFromGitHub {
    owner = "sahaj-b";
    repo = "ghostty-cursor-shaders";
    rev = "0a274beac8b93ee6ce6b94402b7313a0417b8e38";
    hash = "sha256-B7B6K7Ee4uJlW8zzLP3ILgddnbcIQyNimY+rVllzbR0=";
  };
in {
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

    # 为常用 Shell 开启集成（推荐）
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    settings = {
      # 配色走 ghostty 出厂默认（2026-10-16 起与 theme.nix 的 Nix-Periwinkle
      # 解耦，用户要求）。theme.nix 只出字体/字号；毛玻璃（半透明+模糊）归
      # config.kdl 的 niri 窗口规则，与配色无关
      window-theme = "auto";                   # 跟随系统主题

      # 不用 GTK 满配标题栏，改走合成器的简单装饰（niri 下就是自己的边框），
      # 否则 niri 里每个 ghostty 窗口顶上都多一条 GTK 顶栏
      gtk-titlebar = false;

      font-family = theme.font;                # 字体唯一来源是 theme.nix
      font-size = theme.font-size;             # 字号同上
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
    	# ── 关闭多标签页：解绑 ghostty 全部标签默认键（new_tab/切tab/goto_tab），
    	#    tab 从此无法用键盘创建，单标签时本就没有 tab 栏。附带效果：
    	#    alt+1..9 不再被终端吃掉，能透传给里面的 TUI 程序
    	"ctrl+t=unbind"
    	"ctrl+shift+t=unbind"
    	"ctrl+shift+w=unbind"
    	"ctrl+tab=unbind"
    	"ctrl+shift+tab=unbind"
    	"ctrl+shift+left=unbind"
    	"ctrl+shift+right=unbind"
    	"ctrl+shift+arrow_left=unbind"
    	"ctrl+shift+arrow_right=unbind"
    	"ctrl+page_up=unbind"
    	"ctrl+page_down=unbind"
    	"alt+1=unbind"
    	"alt+2=unbind"
    	"alt+3=unbind"
    	"alt+4=unbind"
    	"alt+5=unbind"
    	"alt+6=unbind"
    	"alt+7=unbind"
    	"alt+8=unbind"
    	"alt+9=unbind"
    	"alt+digit_1=unbind"
    	"alt+digit_2=unbind"
    	"alt+digit_3=unbind"
    	"alt+digit_4=unbind"
    	"alt+digit_5=unbind"
    	"alt+digit_6=unbind"
    	"alt+digit_7=unbind"
    	"alt+digit_8=unbind"
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
