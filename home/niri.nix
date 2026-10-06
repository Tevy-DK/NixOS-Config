# --- niri 用户层（工作环境）---
{ config, pkgs, inputs, ... }:
let
  # 音量速览：ghostty 浮窗显示默认输出/麦克风的音量条与静音状态。
  # 弹出入口统一走 volview-popup（音量键和 Mod+M 都调它）。窗口内每 0.2s
  # 自动刷新（read -t 0.2 轮询，刷新节拍顺便当按键等待，不空转），Esc（或 q）
  # 退出。配色直接用终端 ANSI 色（ghostty 已接 theme.nix 的 ANSI 调色板：
  # 绿=正常、红=已静音、90=暗灰），无需引入主题文件。
  volview = pkgs.writeShellApplication {
    name = "volview";
    runtimeInputs = with pkgs; [ wireplumber gawk ];
    text = ''
      esc=$'\033'
      reset=$'\033[0m'
      dim=$'\033[90m'
      green=$'\033[32m'
      red=$'\033[31m'
      eol=$'\033[K'   # 清到行尾：每帧原地覆写，不清整屏就不闪
      below=$'\033[J' # 清光标以下，兜底行数变化

      bar() {
        pct=$1
        width=40
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
          printf ' %s%s%s %s不可用%s%s\n' "$dim" "$label" "$reset" "$dim" "$reset" "$eol"
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
        printf ' %s%s%s %s%3d%% %s%s%s%s%s\n' "$dim" "$label" "$reset" "$color" "$pct" "$color" "$(bar "$pct")" "$reset" "$tag" "$eol"
      }

      render() {
        printf '%s[H' "$esc" # 只归位不清屏，配合行尾 [K 原地覆写防闪
        row "音量    " "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
        row "麦克风  " "$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null || true)"
        printf '\n %sEsc 退出 · 每 0.2s 自动刷新%s%s%s' "$dim" "$reset" "$eol" "$below"
      }

      printf '%s[2J%s[H' "$esc" "$esc" # 进屏先整屏清一次
      while true; do
        render
        key=""
        if IFS= read -rsn1 -t 0.2 key; then # 0.2s 没按键就超时 → 触发下一帧刷新
          if [ "$key" = "$esc" ]; then
            read -rsn2 -t 0.001 _ || true # 吃掉 Esc 序列（方向键等）的剩余字节
            exit 0
          fi
          if [ "$key" = "q" ]; then
            exit 0
          fi
        fi
      done
    '';
  };
  # 音量键的一体化入口（niri 一个 bind 只允许一个 action，改音量和弹窗得打包
  # 成一个脚本）：先按 $1 改默认输出/麦克风，再弹出 volview 窗口。
  # $1：5%+ / 5%- 调音量，mute-sink / mute-mic 切换静音。
  volkey = pkgs.writeShellApplication {
    name = "volkey";
    runtimeInputs = with pkgs; [ wireplumber ];
    text = ''
      case $1 in
        mute-sink) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle || true ;;
        mute-mic)  wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle || true ;;
        *)         wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ "$1" || true ;;
      esac
      exec volview-popup
    '';
  };

  # 弹出器：volkey（音量键）和 Mod+M 都调它。
  # 已有 volview 窗口就把它搬到当前 workspace 并聚焦，没有才拉起新浮窗。
  # flock 串住并等窗口注册进 niri 再放锁——音量键是 repeating，按住不放时
  # 后续调用要么撞锁退出（窗口还没起来）、要么聚焦现成的，不会连开一串。
  volview-popup = pkgs.writeShellApplication {
    name = "volview-popup";
    runtimeInputs = with pkgs; [ niri jq util-linux ghostty ];
    text = ''
      app=com.dk.volview
      lock=''${XDG_RUNTIME_DIR:-/tmp}/volview-popup.lock
      exec 9>"$lock"
      flock -n 9 || exit 0

      find_window() {
        niri msg --json windows 2>/dev/null \
          | jq -r --arg a "$app" '.[] | select(.app_id == $a) | .id' | head -n 1
      }

      # 聚焦；若窗口残留在别的 workspace，先搬过来，免得把人带过去。
      # 注意 id（workspace_id）和 idx（workspace 序号）是两码事：比较用 id，
      # move 的目标参数收 idx。
      focus() {
        wid=$1
        wsinfo=$(niri msg --json workspaces 2>/dev/null \
          | jq -r '.[] | select(.is_focused) | "\(.id) \(.idx)"')
        cur_id=''${wsinfo%% *}
        cur_idx=''${wsinfo#* }
        wsw=$(niri msg --json windows 2>/dev/null \
          | jq -r --arg a "$app" '.[] | select(.app_id == $a) | .workspace_id' | head -n 1)
        if [ -n "$cur_id" ] && [ -n "$wsw" ] && [ "$wsw" != "$cur_id" ]; then
          niri msg action move-window-to-workspace "$cur_idx" --window-id "$wid" 2>/dev/null || true
        fi
        niri msg action focus-window --id "$wid" 2>/dev/null || true
      }

      wid=$(find_window)
      if [ -n "$wid" ]; then
        focus "$wid"
        exit 0
      fi

      setsid -f ghostty --class="$app" --window-width=68 --window-height=6 -e volview

      # 等窗口注册（最多 1.5s），注册好顺手聚焦一次再放锁
      i=0
      while [ "$i" -lt 15 ]; do
        sleep 0.1
        wid=$(find_window)
        if [ -n "$wid" ]; then
          focus "$wid"
          exit 0
        fi
        i=$(( i + 1 ))
      done
    '';
  };
in
{
  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  # TUI 托盘（Mod+Y）：niri 环境没有状态栏，clash-verge / fcitx5 的
  # StatusNotifierItem 图标和菜单需要一个宿主，tray-tui 在终端里当这个宿主。
  # hyprland 环境不装：caelestia 的栏自带托盘。
  #
  # XWayland：niri ≥25.08 内置 xwayland-satellite 集成，PATH 里有 ≥0.7 的
  # satellite 即可全自动 —— 有 X11 客户端连入时按需创建 X11 socket、导出
  # DISPLAY、拉起 satellite（挂了自动重启）。所以这里只装包：不要再手动
  # spawn-at-startup，也不要在 config.kdl 的 environment 里设 DISPLAY。
  # nixpkgs 的 satellite 包已把 Xwayland 二进制包进 PATH；剪贴板、IME
  # （XIM→text-input-v3，fcitx5 的 XMODIFIERS 见 system/fcitx5.nix）、
  # 高分屏原生分辨率缩放都由 satellite 自己处理。
  home.packages = [
    pkgs.tray-tui
    pkgs.xwayland-satellite
    volview
    volview-popup
    volkey
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
