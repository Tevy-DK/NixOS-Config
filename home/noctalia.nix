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
#   壁纸自动取色 theme.source = "wallpaper"：调色板从当前壁纸生成，并经内置
#               模板（gtk3/gtk4/niri/qt/btop/cava，见 templates 注释）分发到
#               GTK/Qt/niri/TUI 配色；ghostty 改用下面的 user 模板，以便把
#               文本光标从 foreground（看起来是白色）改成 primary 强调色。
#
# Hooks 在 Nix 侧合并进 settings（而不是写死在 noctalia-config.toml）：
# 命令需要 cursor-theme-sync 的真实 Store 路径，lib.getExe 只能在求值期拿到。
# Noctalia 把 [hooks] 当作普通配置段读取，最终仍落在 config.toml。
#
# 不要同时启用社区插件 vn1k/cursor：它也会写 ~/.config/niri/cursor.kdl、
# GTK settings.ini 和 dconf cursor-*，会和 cursor-theme-sync 互相覆盖。
{ pkgs, lib, theme, ... }:
let
  cursorSync = import ../lib/cursor-theme-sync.nix { inherit pkgs theme; };

  baseSettings = builtins.fromTOML (builtins.readFile ./noctalia-config.toml);

  # Noctalia 的 builtin ghostty 模板把 cursor-color 映射到 terminal_cursor，
  # 而 wallpaper 调色板里它就等于 foreground —— 深色模式下看起来是白的。
  # 复制同一份模板，只把 cursor-color/cursor-text 换成 primary/on_primary；
  # 其余 ANSI/背景/选中色仍完全由 Noctalia 的 token 生成。
  ghosttyTemplateSource = builtins.readFile
    "${pkgs.noctalia}/share/noctalia/assets/templates/ghostty/ghostty";

  ghosttyTemplate = pkgs.writeText "ghostty-noctalia-template" (
    assert lib.assertMsg
      (
        lib.hasInfix "cursor-color = {{colors.terminal_cursor.default.hex}}" ghosttyTemplateSource
        && lib.hasInfix "cursor-text = {{colors.terminal_cursor_text.default.hex}}" ghosttyTemplateSource
      )
      "Noctalia 的 ghostty 模板 cursor 行变了，请更新 home/noctalia.nix 的替换规则";
    lib.replaceStrings
      [
        "cursor-color = {{colors.terminal_cursor.default.hex}}"
        "cursor-text = {{colors.terminal_cursor_text.default.hex}}"
      ]
      [
        "cursor-color = {{colors.primary.default.hex}}"
        "cursor-text = {{colors.on_primary.default.hex}}"
      ]
      ghosttyTemplateSource
  );

  baseTemplates = baseSettings.theme.templates;

  themeSettings = baseSettings.theme // {
    templates = baseTemplates // {
      user.ghostty = {
        input_path = toString ghosttyTemplate;
        output_path = "$XDG_CONFIG_HOME/ghostty/themes/noctalia";
        post_hook = "bash ${pkgs.noctalia}/share/noctalia/assets/templates/ghostty/apply.sh";
        hook_async = false;
      };
    };
  };
in
{
  programs.noctalia = {
    enable = true;
    # 与系统层同一个包；不为 null 才会启用上面的构建期配置校验
    package = pkgs.noctalia;

    settings = baseSettings // {
      theme = themeSettings;
      hooks = {
        # IPC 就绪后按当前解析模式同步一次（启动时 theme_mode_changed 不会补发）。
        started = "${lib.getExe cursorSync} --apply";
        # 模板已应用后触发；NOCTALIA_THEME_MODE 是解析后的 dark/light。
        theme_mode_changed = "${lib.getExe cursorSync} --mode \"$NOCTALIA_THEME_MODE\"";
      };
    };
  };
}
