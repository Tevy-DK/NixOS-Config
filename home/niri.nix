# --- niri 用户层（工作环境）---
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  xdg.configFile."niri/config.kdl".source = ./config.kdl;
  xdg.configFile."niri/border.kdl".source = ./border.kdl;

  # noctalia 的 niri 模板把壁纸调色板渲染成 ~/.config/niri/noctalia.kdl，
  # config.kdl 末尾 include 它。首次启动（noctalia 还没跑过模板）时该文件
  # 不存在，niri 的 include 读取失败会判整个配置无效——这里建一个空占位：
  # 只在缺失时创建（test -f 守卫），绝不覆盖 noctalia 的运行时写入。
  home.activation.noctaliaKdlBootstrap = lib.hm.dag.entryBefore ["writeBoundary"] ''
    if [ ! -f "$HOME/.config/niri/noctalia.kdl" ]; then
      mkdir -p "$HOME/.config/niri"
      printf '%s\n' "// 占位文件：noctalia niri 模板首次应用前保持配置可解析" > "$HOME/.config/niri/noctalia.kdl"
    fi
  '';

  # 桌面外壳（bar/启动器/控制中心/通知/OSD/托盘/剪贴板/锁屏/电源菜单/壁纸/polkit）
  # 全部由 noctalia 接管：用户配置在 home/noctalia.nix（config.toml，构建期校验），
  # 包与 systemd 服务在 system/niri.nix 的 programs.noctalia。
  # 旧的自制品（tray-tui 托盘、volview 音量浮窗、polkit-gnome、fuzzel、awww）已撤。

  # XWayland：niri ≥25.08 内置 xwayland-satellite 集成，PATH 里有 ≥0.7 的
  # satellite 即可全自动 —— 有 X11 客户端连入时按需创建 X11 socket、导出
  # DISPLAY、拉起 satellite（挂了自动重启）。所以这里只装包：不要再手动
  # spawn-at-startup，也不要在 config.kdl 的 environment 里设 DISPLAY。
  # nixpkgs 的 satellite 包已把 Xwayland 二进制包进 PATH；剪贴板、IME
  # （XIM→text-input-v3，fcitx5 的 XMODIFIERS 见 system/fcitx5.nix）、
  # 高分屏原生分辨率缩放都由 satellite 自己处理。
  home.packages = [
    pkgs.xwayland-satellite
  ];
}
