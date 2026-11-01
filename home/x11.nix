# --- x11 ---
# XWayland（niri 通过 xwayland-satellite 按需拉起）里的应用不在 Wayland
# 协议保护伞下：字体渲染、光标、GTK 主题分别靠 X 资源和 GTK settings.ini。
# 这里只补 X server 资源；GTK 主题名由 cursor-theme-sync 镜像到 settings.ini
# （见 home/cursor-theme.nix），光标别名与尺寸也在那里维护。
#
# 加载时机：niri 启动时 DISPLAY 还不存在（satellite 是按需启动的），
# 所以不能用 spawn-at-startup。用 systemd path 单元盯 /tmp/.X11-unix 的
# 增删事件，X server 出现/重启时把资源合并进去；HM 激活时如果 X server
# 已在跑，则在激活脚本里直接补一次。事件驱动、无常驻轮询。
{ config, lib, pkgs, theme, ... }:
let
  xrdb = lib.getExe pkgs.xrdb;
  resources = "${config.home.homeDirectory}/.Xresources";

  merge = pkgs.writeShellScript "xresources-merge" ''
    set -u
    rc=0

    # path 单元可能在 socket 刚创建时运行，短暂等一下 X* socket。
    for ((i = 0; i < 50; i++)); do
      set -- /tmp/.X11-unix/X*
      [ -e "$1" ] && break
      ${lib.getExe' pkgs.coreutils "sleep"} 0.1
    done

    for socket in /tmp/.X11-unix/X*; do
      [ -S "$socket" ] || continue
      DISPLAY=":''${socket##*/X}" ${xrdb} -merge ${lib.escapeShellArg resources} || rc=1
    done

    exit "$rc"
  '';
in
{
  # Xft 抗锯齿/微调 + Xcursor 稳定别名（深浅模式由别名目标切换）
  xresources.properties = {
    "Xft.antialias" = true;
    "Xft.autohint" = false;
    "Xft.hinting" = true;
    "Xft.hintstyle" = "hintslight";
    "Xft.lcdfilter" = "lcddefault";
    "Xft.rgba" = "rgb";
    "Xft.dpi" = 96;
    "Xcursor.theme" = theme.cursor-alias;
    "Xcursor.size" = theme.cursor-size;
  };

  # XWayland 通常按需启动；但 HM 激活时它可能已经在跑，path 单元只响应
  # 后续增删事件，这里补一次当前 display 的合并。
  home.activation.xresourcesMerge = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if ls /tmp/.X11-unix/X* >/dev/null 2>&1; then
      ${merge} || true
    fi
  '';

  systemd.user.services.xresources = {
    Unit = {
      Description = "Merge Xresources into XWayland displays";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = merge;
    };
  };

  systemd.user.paths.xresources = {
    Unit = {
      Description = "Watch for XWayland displays";
      PartOf = [ "graphical-session.target" ];
    };
    Path = {
      # PathExists* 只要路径存在就会反复触发，单次 oneshot 会让 unit
      # 连续启动直到 start-limit；PathChanged 只在目录内容增删时触发。
      PathChanged = "/tmp/.X11-unix";
      Unit = "xresources.service";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
