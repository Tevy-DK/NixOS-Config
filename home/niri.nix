# --- niri 用户层（工作环境）---
{ config, pkgs, inputs, ... }:
let
  # 音量速览（Mod+M）：极小 ghostty 浮窗里显示默认输出/麦克风的音量条与静音状态。
  # Esc（或 q）退出，其他键刷新。配色直接用终端 ANSI 色（ghostty 已接 theme.nix：
  # 绿=accent 蕨绿，红=urgent，90=暗灰），无需引入主题文件。
  volview = pkgs.writeShellApplication {
    name = "volview";
    runtimeInputs = with pkgs; [ wireplumber gawk ];
    text = ''
      esc=$'\033'
      reset=$'\033[0m'
      dim=$'\033[90m'
      green=$'\033[32m'
      red=$'\033[31m'

      bar() {
        pct=$1
        width=20
        filled=$(( pct * width / 100 ))
        out=""
        i=0
        while [ "$i" -lt "$filled" ]; do
          out+="━"
          i=$(( i + 1 ))
        done
        while [ "$i" -lt "$width" ]; do
          out+="░"
          i=$(( i + 1 ))
        done
        printf '%s' "$out"
      }

      # $1=已补齐宽度的标签 $2=wpctl get-volume 的输出
      row() {
        label=$1
        line=$2
        if [ -z "$line" ]; then
          printf ' %s%s%s %s不可用%s\n' "$dim" "$label" "$reset" "$dim" "$reset"
          return
        fi
        vol=''${line#*: }
        muted=0
        case $vol in
          *"[MUTED]"*) muted=1 ;;
        esac
        vol=''${vol%% \[*}
        pct=$(gawk -v v="$vol" 'BEGIN { v = (v > 1) ? 1 : v; printf "%d", v * 100 + 0.5 }')
        color=$green
        tag=""
        if [ "$muted" -eq 1 ]; then
          color=$red
          tag="  已静音"
        fi
        printf ' %s%s%s %s%3d%% %s%s%s%s\n' "$dim" "$label" "$reset" "$color" "$pct" "$color" "$(bar "$pct")" "$reset" "$tag"
      }

      render() {
        printf '%s[2J%s[H' "$esc" "$esc"
        row "音量    " "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
        row "麦克风  " "$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null || true)"
        printf '\n %sEsc 退出 · 任意键刷新%s\n' "$dim" "$reset"
      }

      while true; do
        render
        key=""
        IFS= read -rsn1 key || exit 0
        if [ "$key" = "$esc" ]; then
          read -rsn2 -t 0.001 _ || true # 吃掉 Esc 序列（方向键等）的剩余字节
          exit 0
        fi
        if [ "$key" = "q" ]; then
          exit 0
        fi
      done
    '';
  };
in
{
  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  # TUI 托盘（Mod+Y）：niri 环境没有状态栏，clash-verge / fcitx5 的
  # StatusNotifierItem 图标和菜单需要一个宿主，tray-tui 在终端里当这个宿主。
  # hyprland 环境不装：caelestia 的栏自带托盘。
  home.packages = [
    pkgs.tray-tui
    volview
  ];

  # polkit 认证弹窗代理（GTK 版；起法与 home/hyprland.nix 的 hyprpolkitagent 同款）
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome Authentication Agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
