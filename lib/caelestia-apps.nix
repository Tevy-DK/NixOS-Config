{ pkgs, theme }:
let
  inherit (pkgs) lib;
  gtkSync = import ./gtk-theme-sync.nix { inherit pkgs; };
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
  runtimeInputs = [ pkgs.coreutils pkgs.jq pkgs.dconf pkgs.systemd pkgs.procps gtkSync ];
  text = ''
    mode=dark
    colours=
    state="''${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/scheme.json"
    cfg="''${XDG_CONFIG_HOME:-$HOME/.config}"

    case "''${1:-}" in
      --hook)
        mode="''${SCHEME_MODE:?SCHEME_MODE missing}"
        colours="''${SCHEME_COLOURS:?SCHEME_COLOURS missing}"
        ;;
      --apply)
        if [ -r "$state" ] && jq -e . "$state" >/dev/null 2>&1; then
          mode="$(jq -r '.mode' "$state")"
          colours="$(jq -c '.colours' "$state")"
        else
          mode="$(jq -r '.mode' ${fallbackFile})"
          colours="$(jq -c '.colours' ${fallbackFile})"
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

    # 运行中的实例重载；不在跑就跳过。
    busctl --user --timeout=2 call com.mitchellh.ghostty /com/mitchellh/ghostty \
      org.gtk.Actions Activate 'sava{sv}' reload-config 0 0 >/dev/null 2>&1 || true
    pkill -USR2 -x cava 2>/dev/null || true
    hyprctl reload >/dev/null 2>&1 || true
  '';
}
