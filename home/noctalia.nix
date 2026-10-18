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
#               模板（gtk3/gtk4/niri/qt，见 templates 注释）分发到 GTK/Qt/niri
#               配色——除终端工具链（theme.nix）外全桌面颜色跟壁纸走
{ pkgs, ... }:
{
  programs.noctalia = {
    enable = true;
    # 与系统层同一个包；不为 null 才会启用上面的构建期配置校验
    package = pkgs.noctalia;

    settings = builtins.fromTOML (builtins.readFile ./noctalia-config.toml);
  };
}
