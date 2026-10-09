# --- noctalia ---
# Noctalia v5 桌面外壳的用户配置。包 / systemd 用户服务 / 配套系统服务
# （NetworkManager、bluetooth、upower、power-profiles-daemon）在 system/niri.nix
# 的 programs.noctalia，这里只管 ~/.config/noctalia/config.toml。
# settings 是强类型 TOML（nixpkgs tomlFormat 生成），且构建期会跑
# `noctalia config validate` —— 键名写错直接构建失败，改完 eval 一次就能抓到。
#
# 三个关键效果（配合 home/config.kdl 的 niri 侧规则）：
#   玻璃面板    shell.panel.transparency_mode = "glass"：面板半透明 + 卡片透底，
#               模糊由 noctalia 上报区域、niri 的 layer-rule/blur 节点执行
#   概览模糊壁纸 backdrop.enabled：壁纸渲染进 niri backdrop（layer-rule
#               place-within-backdrop），Mod+D 概览里壁纸保持可见并带模糊
#   壁纸自动取色 theme.source = "wallpaper"：调色板从当前壁纸生成，
#               与 theme.nix「颜色跟壁纸走」的思路一致
{ pkgs, ... }:
{
  programs.noctalia = {
    enable = true;
    # 与系统层同一个包；不为 null 才会启用上面的构建期配置校验
    package = pkgs.noctalia;

    settings = {
      shell = {
        # 概览（Mod+D）里直接打字启动应用（noctalia 提供键盘焦点层）
        niri_overview_type_to_launch_enabled = true;
        # polkit 认证弹窗由 noctalia 出，home/niri.nix 的 polkit-gnome 已撤
        polkit_agent = true;
      };

      # 玻璃：面板 solid | soft | glass 三档，glass 最透。
      # 注意它只管浮动面板和卡片；bar 的透明度是独立的 background_opacity（默认
      # 1.0 不透明）——noctalia 会给 bar 上报模糊区域，但底子不透就看不见。
      shell.panel.transparency_mode = "glass";

      # bar 半透明，让 niri 的合成器模糊透出来（见 config.kdl 的 layer-rule）
      bar.main.background_opacity = 0.6;

      # 设置窗口背景透明（默认 false = 1.0 全不透明，niri 侧的 blur 规则会被
      # 不透明底盖住看不见）；配合 config.kdl 里 dev.noctalia.Noctalia 的
      # background-effect 才有毛玻璃
      shell.settings_window_translucent = true;

      # 台式机：默认 end 列表去掉电池和亮度（无电池、无背光）
      bar.main.end = [
        "media"
        "tray"
        "notifications"
        "clipboard"
        "network"
        "volume"
        "control-center"
        "session"
      ];

      # 概览模糊壁纸副本：关闭。noctalia 的模糊副本层是静态常开的，放进
      # backdrop 后会和清晰壁纸层叠放，要么盖住模糊（概览看不到模糊）要么把
      # 桌面一起糊掉；DMS 那种「概览打开时壁纸层原位模糊」noctalia 没有实现。
      # 概览构图走 DMS 同款：清晰壁纸层进 backdrop（见 home/config.kdl），
      # 概览里壁纸连续一整块、窗口浮在上面。
      backdrop = {
        enabled = false;
      };

      theme = {
        mode = "dark";
        source = "wallpaper"; # m3-tonal-spot 默认方案；builtin 可换 Noctalia/Catppuccin 等
      };

      # 壁纸目录沿用原 awww 方案的 ~/Images；选图走 noctalia 壁纸面板
      # （Mod+Shift+W 或启动器 /wall），不再需要 wallpick 脚本
      wallpaper.directory = "~/Images";
    };
  };
}
