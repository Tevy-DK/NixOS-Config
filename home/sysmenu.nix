# sysmenu —— Omarchy 式的管理中心（fzf 菜单，在终端里跑）
# 用法：终端里直接敲 `sysmenu`，或桌面上按 Mod+S（会在 ghostty 里打开）。
# 功能：重建/测试/回滚、GC 清理、btop、快速启动、会话控制。
# 借鉴 koru CLI 的两个细节：flock 共享锁防止并发 rebuild；操作日志落盘可追溯。
# hostname 由 flake.nix 按当前构建的机器注入：切到 hyprland 娱乐环境时
# sysmenu 重建的就是 hyprland，不会串到别的机器。
{ pkgs, hostname, ... }:
let
  # 这份仓库在 NixOS 机器上的路径；换了位置就改这里
  flakeDir = "/home/dk/coding/NixOS-Config";
in
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "sysmenu";
      runtimeInputs = with pkgs; [ coreutils util-linux fzf btop swaylock ];
      text = ''
        set -euo pipefail

        flake="${flakeDir}"
        host="${hostname}"
        sudo="${pkgs.sudo}/bin/sudo"

        # 锁与日志（同 koru 的做法）
        state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/sysmenu"
        mkdir -p "$state_dir"
        lock="$state_dir/rebuild.lock"
        log="$state_dir/operation.log"

        menu=(
          "系统 · 应用新配置 (switch)"
          "系统 · 仅测试 (test)"
          "系统 · 更新 flake.lock 并应用"
          "代际 · 回滚到上一代"
          "清理 · 删除 7 天前的旧代并 GC"
          "清理 · 优化 nix store"
          "监控 · btop"
        )
        # fuzzel 只随 niri 环境安装：装了才给快速启动入口
        command -v fuzzel >/dev/null 2>&1 && menu+=("快速启动 · 应用菜单 (fuzzel)")
        menu+=(
          "会话 · 锁屏"
          "会话 · 重启"
          "会话 · 关机"
        )

        choice=$(printf '%s\n' "''${menu[@]}" | fzf --prompt='❯ ' --reverse --border --height=100% \
          --header=' NixOS 管理中心（Esc 退出）')
        # Esc / 空选直接退出
        [[ -n "$choice" ]] || exit 0

        # 改动系统状态的命令：加锁 + 写日志；跑完停一下让输出可见
        run() {
          local cmd="$1" rc=0
          exec 200>"$lock"
          if ! flock -n 200; then
            echo "另一个 sysmenu 操作正在进行（锁：$lock），稍后再试。"
            read -rp '按回车关闭'
            return 0
          fi
          printf '── %s  %s\n' "$(date '+%F %T')" "$cmd" | tee -a "$log"
          eval "$cmd" 2>&1 | tee -a "$log" || rc=$?
          printf '── %s  退出码 %s\n' "$(date '+%F %T')" "$rc" | tee -a "$log"
          echo
          read -rp '—— 完成，按回车关闭 ——'
        }

        case "$choice" in
          "系统 · 应用新配置 (switch)")      run "$sudo nixos-rebuild switch --flake \"$flake#$host\"" ;;
          "系统 · 仅测试 (test)")            run "$sudo nixos-rebuild test --flake \"$flake#$host\"" ;;
          "系统 · 更新 flake.lock 并应用")   run "(cd \"$flake\" && nix flake update) && $sudo nixos-rebuild switch --flake \"$flake#$host\"" ;;
          "代际 · 回滚到上一代")             run "$sudo nixos-rebuild switch --rollback" ;;
          "清理 · 删除 7 天前的旧代并 GC")   run "$sudo nix-collect-garbage -d --delete-older-than 7d" ;;
          "清理 · 优化 nix store")           run "$sudo nix store optimise" ;;
          "监控 · btop")                     run "btop" ;;
          "快速启动 · 应用菜单 (fuzzel)")    setsid fuzzel >/dev/null 2>&1 < /dev/null & exit 0 ;;
          "会话 · 锁屏")                     exec swaylock ;;
          "会话 · 重启")                     run "systemctl reboot" ;;
          "会话 · 关机")                     run "systemctl poweroff" ;;
        esac
      '';
    })
  ];
}
