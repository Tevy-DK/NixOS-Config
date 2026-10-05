# powermenu —— fuzzel 电源菜单（dmenu 模式）：关机 / 重启 / 登出。
# 比 TUI 版省掉整个终端浮窗：fuzzel 是 layer-shell 浮层，即开即走、Esc 天然取消，
# 配色/字体直接复用 launcher.nix 渲染的 fuzzel 主题，无需另写样式。
# 确认步骤用第二次 fuzzel（确认/取消），防误触。
# 桌面按 Mod+X 打开（与 hyprland 档案 Mod+X = caelestia:session 的肌肉记忆一致）；
# 登出走 niri msg，所以本模块仅 niri 档案启用（flake.nix 里 hyprland 覆盖为 false）。
{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "powermenu";
      runtimeInputs = with pkgs; [ fuzzel systemd ];
      text = ''
        set -u

        choice=$(printf '%s\n' 关机 重启 登出 | fuzzel --dmenu --prompt='电源 ❯ ') || exit 0

        case $choice in
          关机) question='确认关机？' ;;
          重启) question='确认重启？' ;;
          登出) question='确认登出？' ;;
          *) exit 0 ;;
        esac

        answer=$(printf '%s\n' 确认 取消 | fuzzel --dmenu --prompt="''${question} ❯ ") || exit 0
        [ "$answer" = "确认" ] || exit 0

        case $choice in
          关机) systemctl poweroff ;;
          重启) systemctl reboot ;;
          登出) niri msg action quit ;;
        esac
      '';
    })
  ];
}
