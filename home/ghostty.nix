{ pkgs, lib, theme, ... }:

let
  # 1. 使用 fetchFromGitHub 声明式地获取着色器仓库
  cursorShaders = pkgs.fetchFromGitHub {
    owner = "sahaj-b";
    repo = "ghostty-cursor-shaders";
    rev = "0a274beac8b93ee6ce6b94402b7313a0417b8e38";
    hash = "sha256-B7B6K7Ee4uJlW8zzLP3ILgddnbcIQyNimY+rVllzbR0=";
  };

  # 主题文件里的色值不带 #（HM 模块的官方写法）；palette 条目保留 #，
  # 两种写法 ghostty 都认，跟模块 README 的示例保持一致
  hex = c: lib.removePrefix "#" c;

  # 深/浅两套主题共用同一套字段，只有色板来源不同。深色继续用 theme.nix
  # 顶层的 Nix Periwinkle；浅色用 terminal-light（只给终端用）。
  dark = {
    inherit (theme) bg fg cursor ansi ansi-bright;
    selection-bg = theme.accent-bg;
    selection-fg = theme.fg;
  };
  light = theme.terminal-light;

  mkTheme = c: {
    background = hex c.bg;
    foreground = hex c.fg;
    cursor-color = hex c.cursor;
    selection-background = hex c.selection-bg;
    selection-foreground = hex c.selection-fg;
    palette = [
      "0=${c.ansi.black}"   "1=${c.ansi.red}"     "2=${c.ansi.green}"   "3=${c.ansi.yellow}"
      "4=${c.ansi.blue}"    "5=${c.ansi.magenta}" "6=${c.ansi.cyan}"    "7=${c.ansi.white}"
      "8=${c.ansi-bright.black}"  "9=${c.ansi-bright.red}"    "10=${c.ansi-bright.green}" "11=${c.ansi-bright.yellow}"
      "12=${c.ansi-bright.blue}"  "13=${c.ansi-bright.magenta}" "14=${c.ansi-bright.cyan}"  "15=${c.ansi-bright.white}"
    ];
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
      # 浅/深成对主题：色值唯一来源是 theme.nix（见下方 themes）。
      # ghostty 通过 xdg-desktop-portal 的 org.freedesktop.appearance
      # color-scheme 跟随系统深浅色；noctalia 的 sync_color_scheme 正好把
      # 当前模式写进 dconf，portal-gtk 再转发，所以不需要额外的切换服务。
      theme = "light:Nix-Periwinkle-Light,dark:Nix-Periwinkle-Dark";
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

      # 深浅色切换会让 ghostty 重载主题，默认弹「配置已重新加载」toast；
      # 自动切换一天弹好几次太吵，只关这一条，其他通知保持默认。
      app-notifications = "no-config-reload";

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

    # 自定义主题文件（~/.config/ghostty/themes/），全部取自 theme.nix
    themes = {
      Nix-Periwinkle-Dark = mkTheme dark;
      Nix-Periwinkle-Light = mkTheme light;
    };
  };

  # Ghostty 不监听配置文件，重建后已经开着的实例不会加载新的成对主题，
  # 要手动按 ctrl+shift+comma。这里在 HM 激活完成后通过 app 级
  # org.gtk.Actions 调 reload-config；没在跑（或没有 session bus）就跳过。
  # nixos-rebuild 的 home-manager-<user>.service 环境里没有会话变量，显式补。
  home.activation.ghosttyReload = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
    if [ -S "$XDG_RUNTIME_DIR/bus" ]; then
      ${lib.getExe' pkgs.systemd "busctl"} --user --timeout=2 call \
        com.mitchellh.ghostty /com/mitchellh/ghostty \
        org.gtk.Actions Activate sava{sv} reload-config 0 0 \
        >/dev/null 2>&1 || true
    fi
  '';
}
