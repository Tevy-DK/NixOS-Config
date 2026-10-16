# --- noctalia ---
# Noctalia v5 桌面外壳的用户配置。包 / systemd 用户服务 / 配套系统服务
# （NetworkManager、bluetooth、upower、power-profiles-daemon）在 system/niri.nix
# 的 programs.noctalia，这里只管 ~/.config/noctalia/config.toml。
#
# v5 的配置分三层：本文件写的 config.toml 是「基础配置」（只读 store 软链）；
# 设置界面 / 壁纸切换 / 锁屏部件编辑的运行时改动写到旁边的 settings.toml
# （overrides，深合并覆盖基础配置，重建不丢）；再往 state.toml 存状态。手动调整
# 后照例把新值搬回这里——重建时 config.toml 整体替换，settings 里缺的键会被抹掉。
# settings 是强类型 TOML（nixpkgs tomlFormat 生成），且构建期会跑
# `noctalia config validate` —— 键名写错直接构建失败，改完 eval 一次就能抓到。
#
# 三个关键效果（配合 home/config.kdl 的 niri 侧规则）：
#   玻璃面板    shell.panel.transparency_mode = "glass"：面板半透明 + 卡片透底，
#               模糊由 noctalia 上报区域、niri 的 layer-rule/blur 节点执行
#   概览壁纸    backdrop.enabled = true 且 blur/tint 全 0：noctalia 的壁纸副本层
#               是一份清晰壁纸，经 config.kdl 的 place-within-backdrop 收进
#               backdrop，Mod+D 概览里壁纸保持可见且连续（DMS 同款构图）
#   壁纸自动取色 theme.source = "wallpaper"：调色板从当前壁纸生成，
#               与 theme.nix「颜色跟壁纸走」的思路一致
{ pkgs, ... }:
{
  programs.noctalia = {
    enable = true;
    # 与系统层同一个包；不为 null 才会启用上面的构建期配置校验
    package = pkgs.noctalia;

    settings = {
      # 壁纸副本层进 niri backdrop：blur/tint 保持 0，副本就是一份清晰壁纸，
      # 不会出现旧版「模糊副本常开」要么盖住清晰壁纸、要么把桌面一起糊掉的取舍
      backdrop = {
        enabled = true;
        blur_intensity = 0.0;
        tint_intensity = 0.0;
      };

      # 浮动顶栏：不透明度 0.6 让 niri 的合成器模糊透出来（见 config.kdl 的
      # layer-rule）；margin_edge/margin_ends 是悬浮留白，smart_auto_hide 自动
      # 隐藏，reserve_space=false 不占 niri 布局空间（窗口可以顶到屏幕上缘）
      bar.main = {
        background_opacity = 0.6;
        end = [
          "media"
          "tray"
          "notifications"
          "clipboard"
          "network"
          "volume"
          "control-center"
          "session"
        ];
        margin_edge = 4;
        margin_ends = 400;
        reserve_space = false;
        smart_auto_hide = true;
        thickness = 32;
      };

      # 控制中心：整幅侧栏（full）+ 900px 宽
      control_center = {
        sidebar = "full";
        width = 900;
      };

      # 天气等位置服务自动定位
      location.auto_locate = true;

      # 锁屏部件：当前整体关闭。widget_order/grid/widget 是部件编辑器记下的布局
      # 状态（login-box 摆在 HDMI-A-1 1920x1080 的位置），照搬保真，重新打开时
      # 位置直接复现。锁屏本体走 ext_session_lock_v1，niri 的 layer-rule 管不到
      # 它（见 config.kdl 的 namespace 清单注释）
      lockscreen_widgets = {
        enabled = false;
        schema_version = 2;
        widget_order = [ "lockscreen-login-box@HDMI-A-1" ];
        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };
        widget."lockscreen-login-box@HDMI-A-1" = {
          box_height = 196.0;
          box_width = 810.0;
          cx = 960.0;
          cy = 898.0;
          output = "HDMI-A-1";
          placement_height = 1080.0;
          placement_width = 1920.0;
          rotation = 0.0;
          type = "login_box";
          settings = {
            background_color = "surface_variant";
            background_opacity = 0.88;
            background_radius = 12.0;
            center_password_text = false;
            input_opacity = 1.0;
            input_radius = 6.0;
            layout = "regular";
            show_caps_lock = true;
            show_keyboard_layout = true;
            show_login_button = true;
            show_media = true;
            show_session_buttons = true;
            show_unlock_hint = true;
            show_weather = true;
          };
        };
      };

      shell = {
        # 概览（Mod+D）里直接打字启动应用（noctalia 提供键盘焦点层）
        niri_overview_type_to_launch_enabled = true;
        # 面板锚定到主 bar；polkit 认证弹窗由 noctalia 出，home/niri.nix 的
        # polkit-gnome 已撤
        panel_anchor_bar = "main";
        polkit_agent = true;

        # 设置窗口背景透明（默认 false = 1.0 全不透明，niri 侧的 blur 规则会被
        # 不透明底盖住看不见）；配合 config.kdl 里 dev.noctalia.Noctalia 的
        # background-effect 才有毛玻璃
        settings_window_translucent = true;

        # 玻璃：面板 solid | soft | glass 三档，glass 最透。注意它只管浮动面板和
        # 卡片；bar 的透明度是独立的 background_opacity（见 bar.main）
        panel = {
          control_center_placement = "floating";
          floating_layer = "top";
          session_placement = "floating";
          session_position = "center";
          shadow = false;
          transparency_mode = "glass";
          wallpaper_placement = "floating";
          wallpaper_position = "center";
        };

        # 会话面板不显示快捷键提示
        session.show_shortcuts = false;

        # noctalia 自绘阴影方向
        shadow.direction = "center";
      };

      theme = {
        # source 切到 builtin / community 时分别用的记忆值；当前 source=wallpaper，
        # 走 m3 系从壁纸取色
        builtin = "Catppuccin";
        community_palette = "Oxocarbon";
        mode = "dark";
        source = "wallpaper";
        wallpaper_scheme = "m3-fruit-salad";

        # 停用 noctalia 的内置应用主题模板：enable_builtin_templates 是总开关，
        # 为 false 时 builtin_ids 完全不生效（v5 源码 enabledBuiltinIds：总开关关
        # 直接返回空集）——gtk3/gtk4/qt 只是设置界面记住的选项，照搬保真，不会
        # 改写 ~/.config/gtk-{3,4}.0/gtk.css，与 home/gtk.nix 无拔河。GTK 颜色归
        # home/gtk.nix 的 theme.nix 命名色（外壳面板仍跟随壁纸，互不相干）。
        # 若日后真要启用模板，把总开关改 true（会开始改写 gtk.css，慎重）。
        templates = {
          builtin_ids = [ "gtk3" "gtk4" "qt" ];
          enable_builtin_templates = false;
        };
      };

      # 壁纸：目录沿用原 awww 方案的 ~/Images；选图走 noctalia 壁纸面板
      # （Mod+Shift+W 或启动器 /wall）。default/last/monitors 是当前壁纸的运行时
      # 状态快照：noctalia 平时把它们写进 settings.toml（overrides 优先于本文件，
      # 换壁纸跟着变），收进基础配置是为了重建后开箱即这份壁纸——调色板
      # source=wallpaper 跟着壁纸走，壁纸状态丢了取色就漂。换壁纸后这里的值过期
      # 无害，下次照例把调整搬回 flake 即可
      wallpaper = {
        directory = "~/Images";
        default.path = "~/Images/c1b1a1d3a1e93e5d0f33e6ae37269ba3cc10fc55.png";
        last.path = "~/Images/c1b1a1d3a1e93e5d0f33e6ae37269ba3cc10fc55.png";
        monitors."HDMI-A-1".path = "~/Images/c1b1a1d3a1e93e5d0f33e6ae37269ba3cc10fc55.png";
      };
    };
  };
}
