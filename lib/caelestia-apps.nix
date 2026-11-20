{ pkgs, theme }:
let
  inherit (pkgs) lib;
  gtkSync = import ./gtk-theme-sync.nix { inherit pkgs; };
  caelestia = lib.getExe pkgs.caelestia-cli;
  hex = c: lib.toLower (lib.removePrefix "#" c);

  # scheme.json 缺失时（首次激活、清场后）使用静态深色兜底。
  fallback = {
    mode = "dark";
    colours = {
      background = hex theme.bg;
      onBackground = hex theme.fg;
      surface = hex theme.bg;
      onSurface = hex theme.fg;
      surfaceContainerHigh = hex theme.bg-alt;
      primary = hex theme.accent;
      onPrimary = hex theme.black;
      secondary = hex theme.accent-2;
      tertiary = hex theme.ansi.magenta;
      term0 = hex theme.ansi.black;
      term1 = hex theme.ansi.red;
      term2 = hex theme.ansi.green;
      term3 = hex theme.ansi.yellow;
      term4 = hex theme.ansi.blue;
      term5 = hex theme.ansi.magenta;
      term6 = hex theme.ansi.cyan;
      term7 = hex theme.ansi.white;
      term8 = hex theme.ansi-bright.black;
      term9 = hex theme.ansi-bright.red;
      term10 = hex theme.ansi-bright.green;
      term11 = hex theme.ansi-bright.yellow;
      term12 = hex theme.ansi-bright.blue;
      term13 = hex theme.ansi-bright.magenta;
      term14 = hex theme.ansi-bright.cyan;
      term15 = hex theme.ansi-bright.white;
    };
  };
  fallbackFile = pkgs.writeText "caelestia-fallback.json" (builtins.toJSON fallback);
in
pkgs.writeShellApplication {
  name = "caelestia-apps";
  # hyprland 提供 hyprctl（末尾 reload 边框）；caelestia-cli 用于重放方案。
  runtimeInputs = [
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.jq
    pkgs.dconf
    pkgs.systemd
    pkgs.procps
    pkgs.caelestia-cli
    pkgs.hyprland
    gtkSync
  ];
  text = ''
    mode=dark
    colours=
    name=
    flavour=
    variant=
    have_state=0
    state="''${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/scheme.json"
    cfg="''${XDG_CONFIG_HOME:-$HOME/.config}"

    case "''${1:-}" in
      --hook)
        mode="''${SCHEME_MODE:?SCHEME_MODE missing}"
        colours="''${SCHEME_COLOURS:?SCHEME_COLOURS missing}"
        ;;
      --apply)
        if [ -r "$state" ] && jq -e . "$state" >/dev/null 2>&1; then
          have_state=1
          mode="$(jq -r '.mode' "$state")"
          colours="$(jq -c '.colours' "$state")"
          name="$(jq -r '.name // empty' "$state")"
          flavour="$(jq -r '.flavour // empty' "$state")"
          variant="$(jq -r '.variant // empty' "$state")"
        else
          # 首次激活/清场后没有方案：用 Caelestia 自己的默认方案播种，
          # 让模板生成完整 gtk/thunar/btop/hypr 产物，而不是只补半套。
          ${caelestia} scheme set --name catppuccin --flavour mocha \
            --mode dark --variant tonalspot || true
          if [ -r "$state" ] && jq -e . "$state" >/dev/null 2>&1; then
            have_state=1
            mode="$(jq -r '.mode' "$state")"
            colours="$(jq -c '.colours' "$state")"
            name="$(jq -r '.name // empty' "$state")"
            flavour="$(jq -r '.flavour // empty' "$state")"
            variant="$(jq -r '.variant // empty' "$state")"
          else
            # 播种也失败（无会话总线等）：退回静态深色兜底，至少把
            # ghostty/cava/dconf 写成可读主题。
            echo "caelestia-apps: 无法播种默认方案，使用静态兜底" >&2
            mode="$(jq -r '.mode' ${fallbackFile})"
            colours="$(jq -c '.colours' ${fallbackFile})"
          fi
        fi
        ;;
      *)
        echo "usage: caelestia-apps --hook | --apply" >&2
        exit 2
        ;;
    esac

    get() { printf '%s' "$colours" | jq -r --arg k "$1" '.[$k] // empty'; }

    # ghostty 主题：Caelestia 无内置模板。
    mkdir -p "$cfg/ghostty/themes"
    tmp="$(mktemp "$cfg/ghostty/themes/.caelestia.XXXXXX")"
    {
      printf 'background = #%s\n' "$(get background)"
      printf 'foreground = #%s\n' "$(get onBackground)"
      printf 'cursor-color = #%s\n' "$(get primary)"
      printf 'cursor-text = #%s\n' "$(get onPrimary)"
      printf 'selection-background = #%s\n' "$(get surfaceContainerHigh)"
      printf 'selection-foreground = #%s\n' "$(get onSurface)"
      for i in $(seq 0 15); do
        printf 'palette = %s=#%s\n' "$i" "$(get "term$i")"
      done
    } > "$tmp"
    mv "$tmp" "$cfg/ghostty/themes/caelestia"

    # cava 主题：只写主题文件，主配置仍归 HM。
    mkdir -p "$cfg/cava/themes"
    tmp="$(mktemp "$cfg/cava/themes/.caelestia.XXXXXX")"
    {
      printf '[color]\n'
      printf "background = '#%s'\n" "$(get background)"
      printf "foreground = '#%s'\n" "$(get onBackground)"
      printf 'gradient = 1\n'
      printf 'gradient_count = 3\n'
      printf "gradient_color_1 = '#%s'\n" "$(get primary)"
      printf "gradient_color_2 = '#%s'\n" "$(get secondary)"
      printf "gradient_color_3 = '#%s'\n" "$(get tertiary)"
    } > "$tmp"
    mv "$tmp" "$cfg/cava/themes/caelestia"

    # Caelestia 的 apply_gtk 写死 adw-gtk3-dark；这里按 mode 纠正。
    if [ "$mode" = light ]; then gtk_theme=adw-gtk3; else gtk_theme=adw-gtk3-dark; fi
    dconf write /org/gnome/desktop/interface/gtk-theme "'$gtk_theme'" 2>/dev/null || true
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-$mode'" 2>/dev/null || true
    dconf write /org/gnome/desktop/interface/icon-theme "'Tela'" 2>/dev/null || true

    # X11/XWayland 的 GTK 只读 settings.ini；复用 niri 的同一脚本。
    gtk-theme-sync --mode "$mode" || true

    # 激活清场会删掉 thunar.css / btop 主题 / hypr/scheme/current.*；
    # gtk.css 只在仍是 niri import/软链时才被定向删除。本脚本只补
    # ghostty/cava，因此状态文件存在时用同一方案重放一次，让 Caelestia
    # 的 apply_colours 重新生成上述产物并刷新边框。
    # 放在本脚本写完之后：apply_gtk 写 adw-gtk3-dark，随后的 postHook
    # （--hook，不会再进 --apply，无递归）把它按 mode 纠正，保证最后写入。
    if [ "$have_state" = 1 ]; then
      if [ -n "$name" ] && [ -n "$mode" ] && [ -n "$variant" ]; then
        set -- scheme set --name "$name" --mode "$mode" --variant "$variant"
        if [ -n "$flavour" ]; then
          set -- "$@" --flavour "$flavour"
        fi
        status=0
        ${caelestia} "$@" || status=$?
        if [ "$status" -ne 0 ]; then
          echo "caelestia-apps: 方案重放失败（exit $status），继续激活" >&2
        fi
      else
        echo "caelestia-apps: scheme.json 缺 name/mode/variant，跳过方案重放" >&2
      fi
    fi

    # 最后兜底：重放失败或模板异常时 gtk.css 不能缺，也不能残留 niri 的
    # noctalia import。用临时文件 + mv 覆盖，旧路径是软链时也不会写进 store。
    for v in 3 4; do
      f="$cfg/gtk-$v.0/gtk.css"
      if [ ! -s "$f" ] || grep -q 'noctalia.css' "$f" 2>/dev/null; then
        mkdir -p "$cfg/gtk-$v.0"
        tmp="$(mktemp "$cfg/gtk-$v.0/.gtk.css.XXXXXX")"
        {
          printf '@define-color accent_color #%s;\n' "$(get primary)"
          printf '@define-color accent_bg_color #%s;\n' "$(get primary)"
          printf '@define-color accent_fg_color #%s;\n' "$(get onPrimary)"
          printf '@define-color window_bg_color #%s;\n' "$(get background)"
          printf '@define-color window_fg_color #%s;\n' "$(get onBackground)"
          printf '@define-color view_bg_color #%s;\n' "$(get background)"
          printf '@define-color view_fg_color #%s;\n' "$(get onBackground)"
          printf '@define-color headerbar_bg_color #%s;\n' "$(get surfaceContainerHigh)"
          printf '@define-color headerbar_fg_color #%s;\n' "$(get onBackground)"
          printf '@define-color card_bg_color #%s;\n' "$(get surfaceContainerHigh)"
        } > "$tmp"
        mv -f "$tmp" "$f"
      fi
    done

    # 运行中的实例重载；不在跑就跳过。
    busctl --user --timeout=2 call com.mitchellh.ghostty /com/mitchellh/ghostty \
      org.gtk.Actions Activate 'sava{sv}' reload-config 0 0 >/dev/null 2>&1 || true
    pkill -USR2 -x cava 2>/dev/null || true
    hyprctl reload >/dev/null 2>&1 || true
  '';
}
