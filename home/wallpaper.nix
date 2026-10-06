# --- 壁纸 ---
# awww 壁纸引擎（原 swww，上游已改名，nixpkgs 跟随） + fuzzel 选图器，只随 niri 工作环境安装（flake.nix 档案覆盖），
# hyprland 娱乐环境的壁纸由 caelestia 接管。
# 两个脚本：
#   wallpaper  开机自启（config.kdl spawn-at-startup）：确保 awww-daemon 在跑，
#              按「上次选的 > ~/Images 第一张 > 主题渐变兜底」上壁纸
#   wallpick   Mod+Shift+W：fuzzel 列出 ~/Images 选图，首项「随机一张」
#              目录与 hyprland 档案 caelestia 的 wallpaperDir（~/Images）公用
# 选中的壁纸记在 ~/.local/state/wallpaper/current，开机由 wallpaper 恢复。
# 图片由用户自己往目录里放，仓库不带图。
{ pkgs, theme, ... }:
let
  # 兜底壁纸：调色板同源的垂直渐变（bg-alt → black），加少量噪声防色带；
  # 固定 seed 保证求值可复现。壁纸目录一张图都没有时也有底图可看。
  fallback = pkgs.runCommand "nix-periwinkle-wallpaper.png" { } ''
    ${pkgs.imagemagick}/bin/magick \
      -size 1920x1080 gradient:'${theme.bg-alt}'-'${theme.black}' \
      -seed 42 -attenuate 0.35 +noise Gaussian \
      "$out"
  '';

  wallpaper = pkgs.writeShellApplication {
    name = "wallpaper";
    runtimeInputs = with pkgs; [ awww coreutils findutils ];
    text = ''
      state=''${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper/current
      dir=$HOME/Images

      # daemon 不在就拉起来（重复执行无副作用），5 秒起不来就放弃，留着 niri 实色底
      if ! awww query >/dev/null 2>&1; then
        awww-daemon >/dev/null 2>&1 < /dev/null &
        i=0
        while ! awww query >/dev/null 2>&1; do
          i=$(( i + 1 ))
          if [ "$i" -ge 50 ]; then
            exit 0
          fi
          sleep 0.1
        done
      fi

      img=""
      if [ -f "$state" ]; then
        img=$(cat "$state")
      fi
      if [ -z "$img" ] || [ ! -f "$img" ]; then
        img=$(find "$dir" -maxdepth 1 -type f \
          \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \) \
          2>/dev/null | sort | head -n 1 || true)
      fi
      if [ -z "$img" ]; then
        img="${fallback}"
      fi

      awww img --resize crop "$img"
      mkdir -p "$(dirname "$state")"
      printf '%s' "$img" > "$state"
    '';
  };

  wallpick = pkgs.writeShellApplication {
    name = "wallpick";
    runtimeInputs = with pkgs; [ awww fuzzel coreutils findutils ];
    text = ''
      dir=$HOME/Images
      state=''${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper/current

      # daemon 不在（被杀过/开机脚本没跑成）就先补上
      awww query >/dev/null 2>&1 || wallpaper || true

      mkdir -p "$dir"
      mapfile -t paths < <(find "$dir" -maxdepth 1 -type f \
        \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \) \
        2>/dev/null | sort)

      if [ "''${#paths[@]}" -eq 0 ]; then
        printf '%s\n' '壁纸目录是空的：先把图片放进 ~/Images 再来' \
          | fuzzel --dmenu --prompt='壁纸 ❯ ' >/dev/null || true
        exit 0
      fi

      # fuzzel 里只显示文件名，路径另存同序数组回查（同目录下排序一致）
      names=()
      for p in "''${paths[@]}"; do
        names+=("$(basename "$p")")
      done

      menu='随机一张'
      for n in "''${names[@]}"; do
        menu+=$'\n'"$n"
      done

      choice=$(printf '%s\n' "$menu" | fuzzel --dmenu --prompt='壁纸 ❯ ') || exit 0

      case $choice in
        随机一张)
          idx=$(( RANDOM % ''${#paths[@]} ))
          ;;
        *)
          idx=-1
          i=0
          for n in "''${names[@]}"; do
            if [ "$n" = "$choice" ]; then
              idx=$i
              break
            fi
            i=$(( i + 1 ))
          done
          if [ "$idx" -lt 0 ]; then
            exit 0
          fi
          ;;
      esac

      img="''${paths[$idx]}"
      awww img --resize crop "$img"
      mkdir -p "$(dirname "$state")"
      printf '%s' "$img" > "$state"
    '';
  };
in
{
  home.packages = [
    pkgs.awww
    wallpaper
    wallpick
  ];
}
