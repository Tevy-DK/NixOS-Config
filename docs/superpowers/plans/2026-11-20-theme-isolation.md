# 双桌面主题隔离 实施计划 v2

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 两个桌面除光标外主题文件零共享；Hyprland 的应用配色跟随 Caelestia 由壁纸生成的方案（含深浅色），niri 继续由 Noctalia 模板驱动。

**Architecture:** 共享 HOME 下用“单一写入者 + 激活期清场”。Hyprland 上 Caelestia 是唯一调色板来源：它写 `gtk.css`、`hypr/scheme/current.lua`、`btop/themes/caelestia.theme`，并跑 HM 提供的 `postHook` 把同一份 `SCHEME_COLOURS` 写到 ghostty/cava、dconf 和 `settings.ini`。HM 只写结构性配置（字体、光标、图标、btop.conf、cava 主配置、ghostty 主配置）。niri 上反过来：Noctalia 写自己的产物，HM 声明 `gtk.css` 的 import 行。每个档案激活时删除对方的运行时产物。

**Tech Stack:** Nix flakes、NixOS 26.05、Home Manager、Noctalia 5.5.0、Caelestia Shell 2.5.0 / CLI 1.1.3、Hyprland Lua 配置。

**Spec:** 本次需求 + 2026-11-20 现状审计。

## Global Constraints

- 光标唯一共享：`Bibata-Modern-Ice` 24px，`home/cursor-theme.nix` 不动。
- 每个主题文件恰好一个写入者。Hyprland 的色彩文件归 Caelestia（含 postHook）；niri 的色彩文件归 Noctalia + HM。
- 不改变 niri 的视觉结果；niri 只增加“删除 Hyprland 产物”和“HM 声明 gtk.css import”。
- `fastfetch`、`zathura`、`mpv`、`fzf`、`bat` 继续读 `system/theme-hyprland.nix` 的静态深色，不属于本次“跟随 Caelestia”的范围；切到浅色时这几个工具不跟随。
- `home/` 不新增未登记模块文件；新代码只放 `lib/`。
- 四配置必须构建通过：
  - `nix build .#homeConfigurations.desktop-niri.activationPackage`
  - `nix build .#homeConfigurations.desktop-hyprland.activationPackage`
  - `nixos-rebuild build --flake .#desktop-niri`
  - `nixos-rebuild build --flake .#desktop-hyprland`

## 现状审计（2026-11-20，Hyprland 会话实测）

| 事实 | 证据 |
|---|---|
| Noctalia 的 `gtk.css` import 残留污染 Hyprland | `~/.config/gtk-{3,4}.0/gtk.css` 只有 `@import url("noctalia.css");`，mtime 10-17；`noctalia.css` mtime 11-14 |
| Caelestia 默认写所有应用主题 | `cli.json` 只有 `enableGtk:false`；`apply_colours` 对缺省键返回 true |
| 已落盘的 Caelestia 产物 | `cava/config`、`htop/htoprc`、`fuzzel/fuzzel.ini` mtime 11-20 21:32；`qtengine/`、`spicetify/`、`zed/`、`nvtop/`、`Equicord/`、`Vencord/`、`vesktop/` 存在 |
| Caelestia 当前是浅色 | `scheme.json`：`mode:light`、`background:fbf8fb`；`sequences.txt` 是浅色 OSC |
| Caelestia 无 ghostty/cava 模板 | CLI `templates/` 目录只有 gtk/qt/btop/term（OSC）等；ghostty 与 cava 需 postHook 补 |
| `qtengine` 未安装 | `command -v qtengine` 无输出，`enableQt` 无意义，Qt 走 `platformTheme=gtk3` |
| Caelestia 强制 `adw-gtk3-dark` | `theme.py:316` 无视 mode 写死 dark；浅色模式必须由 postHook 纠正 |

## 文件清单

| 文件 | 动作 |
|---|---|
| `lib/caelestia-apps.nix` | 新增：postHook/激活脚本，写 ghostty/cava 主题、dconf、settings.ini |
| `lib/theme-residue.nix` | 新增：两份运行时产物路径表 |
| `home/caelestia.nix` | 改：cli.json 选择性开启 + postHook；GTK 改为 null 主题；激活跑 `--apply` |
| `home/hyprland-theme.nix` | 改：btop/cava/ghostty 指向 Caelestia；删静态 Nix-Periwinkle 死代码；挂清场 |
| `home/gtk.nix` | 改：niri 的 `gtk.css` import + force；挂清场 |
| `home/cava.nix` | 改：`force = true` |
| `home/ghostty.nix` | 改：Noctalia 占位只在 niri；Hyprland 占位 `themes/caelestia` |
| `home/hyprland.lua` | 改：读取 `hypr/scheme/current.lua`，替换写死颜色 |
| `flake.nix` | 改：只更新主题归属注释 |
| `system/theme.nix`、`system/theme-hyprland.nix`、`home/themes.nix` | 改：注释写明写入者与例外 |

---

## Task 1: Caelestia 作为 Hyprland 调色板源

**Files:**
- Create: `lib/caelestia-apps.nix`
- Modify: `home/caelestia.nix`

**Interfaces:**
- `import ../lib/caelestia-apps.nix { inherit pkgs theme; }` → 可执行 `caelestia-apps`，支持 `--hook` / `--apply`。
- `--hook` 读取环境 `SCHEME_MODE`、`SCHEME_COLOURS`（Caelestia `apply_colours` 注入）。
- `--apply` 读取 `${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/scheme.json`；文件缺失时用 `theme-hyprland.nix` 的深色兜底。

- [ ] **Step 1: 建 `lib/caelestia-apps.nix`**

```nix
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
      org.gtk.Actions Activate sava{sv} reload-config 0 0 >/dev/null 2>&1 || true
    pkill -USR2 -x cava 2>/dev/null || true
    hyprctl reload >/dev/null 2>&1 || true
  '';
}
```

- [ ] **Step 2: `home/caelestia.nix` 改成选择性开启**

```nix
{ pkgs, lib, theme, ... }:
let
  caelestiaApps = import ../lib/caelestia-apps.nix { inherit pkgs theme; };
in {
  xdg.configFile = {
    "caelestia/shell.json".text = builtins.toJSON (builtins.fromJSON (builtins.readFile ./shell.json));
    "caelestia/cli.json".text = builtins.toJSON {
      theme = {
        enableHypr = true;      # ~/.config/hypr/scheme/current.lua
        enableGtk = true;       # gtk.css + thunar.css + dconf
        enableTerm = true;      # 运行中终端的 OSC 10/11/12/4
        enableBtop = true;      # btop/themes/caelestia.theme
        enableCava = false;     # 会整份覆盖 HM 的 cava/config，交给 postHook
        enableQt = false;       # qtengine 未安装
        enableHtop = false;
        enableFuzzel = false;
        enableNvtop = false;
        enableDiscord = false;
        enableSpicetify = false;
        enablePandora = false;
        enableWarp = false;
        enableChromium = false;
        enableZed = false;
        iconTheme = "Tela";     # 否则 apply_gtk 会把图标改成 Papirus
        postHook = "${lib.getExe caelestiaApps} --hook";
      };
    };
  };

  home.activation.caelestiaAppsApply = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
    ${lib.getExe caelestiaApps} --apply || echo "caelestia-apps: apply failed" >&2
  '';
}
```

- [ ] **Step 3: 构建**

Run: `nix build .#homeConfigurations.desktop-hyprland.activationPackage --no-link`
Expected: exit 0。

- [ ] **Step 4: 验证 hook 在方案切换时写对文件**

```bash
touch /tmp/m
caelestia scheme set -m light
find ~/.config/ghostty/themes ~/.config/cava/themes ~/.config/gtk-3.0 ~/.config/hypr/scheme -newer /tmp/m -type f
```
Expected：`ghostty/themes/caelestia`、`cava/themes/caelestia`、`gtk-*.0/gtk.css`、`hypr/scheme/current.lua` 更新；`cava/config`、`htop/htoprc`、`fuzzel.ini` 不更新。

- [ ] **Step 5: Commit**

```bash
git add lib/caelestia-apps.nix home/caelestia.nix
git commit -m "feat(caelestia): 用 postHook 把壁纸方案分发到 ghostty/cava/GTK"
```

---

## Task 2: Hyprland 的主配置指向 Caelestia 产物

**Files:**
- Modify: `home/hyprland-theme.nix`

**Interfaces:**
- Consumes: Task 1 的 `~/.config/{ghostty/themes/caelestia,cava/themes/caelestia,btop/themes/caelestia.theme}`。

- [ ] **Step 1: btop 改指向 `caelestia`**

```nix
programs.btop.settings.color_theme = lib.mkForce "caelestia";
```

删除整段 `themes.nix-periwinkle`。

- [ ] **Step 2: ghostty 改指向 `caelestia`**

```nix
programs.ghostty.settings.theme = lib.mkForce "caelestia";
```

删除整段 `themes.Nix-Periwinkle`。

- [ ] **Step 3: cava 主配置改指向 `caelestia`**

```nix
xdg.configFile."cava/config" = lib.mkForce {
  text = builtins.replaceStrings [ ''theme = "noctalia"'' ] [ ''theme = "caelestia"'' ]
    (builtins.readFile ./cava-config);
  force = true;
};
```

删除 `cava/themes/nix-periwinkle` 声明。

- [ ] **Step 4: 两处 ghostty 占位分开**

`home/ghostty.nix` 的 `ghosttyNoctaliaThemeBootstrap` 用 `lib.mkIf (desktop == "niri")` 包起来（加 `desktop` 参数），Hyprland 不再创建 `themes/noctalia`。

`home/hyprland-theme.nix` 给 `themes/caelestia` 加占位：

HM 的 ghostty 配置在激活期用 `+validate-config` 校验，`themes/caelestia` 必须先存在：

```nix
home.activation.caelestiaGhosttyThemeBootstrap =
  lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    f="$HOME/.config/ghostty/themes/caelestia"
    if [ ! -e "$f" ]; then
      mkdir -p "$(dirname "$f")"
      printf '%s\n' '# Placeholder: caelestia-apps writes this.' > "$f"
    fi
  '';
```

**Ghostty 跟随链（不是例外）：**

- Caelestia CLI 的 `templates/` 里没有 ghostty（只有 gtk/qt/btop/term 等），所以不能靠 `enable*`。
- `enableTerm` 只对**已存在**的 `/dev/pts` 发 OSC 10/11/12/4，改的是已开窗口；新窗口必须读主题文件。
- 因此 `caelestia-apps` 用同一份 `SCHEME_COLOURS` 写 `~/.config/ghostty/themes/caelestia`：
  `background`/`foreground`/`cursor-*`/`selection-*`/`palette 0..15`。
- HM 只声明 `theme = "caelestia"`、字体、快捷键和 `window-theme = "auto"`；主题文件归 `caelestia-apps`。
- 脚本结尾 `busctl ... reload-config` 让运行中的 ghostty 重读主题；`app-notifications = "no-config-reload"` 已屏蔽重载提示。
- 激活期先用占位文件过 HM 的 `ghostty +validate-config`，随后 `--apply` 原子覆盖。

- [ ] **Step 5: 构建 + 验证文件内容**

```bash
nix build .#homeConfigurations.desktop-hyprland.activationPackage --no-link
home-manager switch --flake .#desktop-hyprland
rg 'color_theme|^theme =' ~/.config/btop/btop.conf ~/.config/ghostty/config ~/.config/cava/config
```
Expected: `color_theme = "caelestia"`、`theme = caelestia`（ghostty）、cava `theme = "caelestia"`。

- [ ] **Step 6: Commit**

```bash
git add home/hyprland-theme.nix home/ghostty.nix
git commit -m "refactor(hyprland): btop/cava/ghostty 跟随 Caelestia 方案"
```

---

## Task 3: GTK 写入权按档案分开

**Files:**
- Modify: `home/gtk.nix`
- Modify: `home/caelestia.nix`

**Interfaces:**
- niri：`~/.config/gtk-{3,4}.0/gtk.css` = HM store 软链，内容 `@import url("noctalia.css");`。
- Hyprland：`gtk.css` 不归 HM，由 Caelestia `apply_gtk` 写；HM 只管 `settings.ini`。

- [ ] **Step 1: `home/gtk.nix` 声明 import 行**

加 `config` 参数，并新增：

```nix
xdg.configFile."gtk-3.0/gtk.css" = {
  text = ''@import url("noctalia.css");'';
  force = true;
};
xdg.configFile."gtk-4.0/gtk.css" = {
  text = ''@import url("noctalia.css");'';
  force = true;
};
```

Noctalia 的 `ensure_gtk_css_import` 看到内容已含 `noctalia.css` + `@import` 会提前返回，不会改写只读软链。

- [ ] **Step 2: `home/caelestia.nix` 让 Caelestia 独占主题名/模式**

```nix
gtk = {
  enable = true;
  theme = null;         # 主题名由 caelestia-apps 按 mode 写 dconf/settings.ini
  colorScheme = null;   # 同上，避免 HM 激活把 prefer-light 重置成 prefer-dark
  font = { name = theme.font; size = theme.font-size-ui; };
  iconTheme = { name = "Tela"; package = pkgs.tela-icon-theme; };
};
home.packages = [ pkgs.caelestia-shell pkgs.caelestia-cli pkgs.adw-gtk3 ];
```

保留 `"gtk-3.0/settings.ini".force = true` 与 `"gtk-4.0/settings.ini".force = true`。不要声明 Hyprland 的 `gtk.css`。

- [ ] **Step 3: 构建两个档案**

```bash
nix build .#homeConfigurations.desktop-niri.activationPackage --no-link
nix build .#homeConfigurations.desktop-hyprland.activationPackage --no-link
```

- [ ] **Step 4: 验证**

Hyprland：
```bash
rg -q noctalia ~/.config/gtk-3.0/gtk.css && echo BAD || echo OK   # 期望 OK
dconf read /org/gnome/desktop/interface/gtk-theme
```
niri：
```bash
cat ~/.config/gtk-3.0/gtk.css               # @import url("noctalia.css");
```

- [ ] **Step 5: Commit**

```bash
git add home/gtk.nix home/caelestia.nix
git commit -m "refactor(gtk): gtk.css 归 niri，主题名/模式归 Caelestia"
```

---

## Task 4: 双向残留清场

**Files:**
- Create: `lib/theme-residue.nix`
- Modify: `home/hyprland-theme.nix`（activation）
- Modify: `home/gtk.nix`（activation）
- Modify: `home/cava.nix`

**Interfaces:**
- `import ../lib/theme-residue.nix { inherit (config.xdg) configHome dataHome; }` → `{ noctaliaArtifacts :: [string]; caelestiaArtifacts :: [string]; }`，绝对路径。
- 两处 activation 名分别是 `themeResidueCleanupNiri`（`home/gtk.nix`）和
  `themeResidueCleanupHyprland`（`home/hyprland-theme.nix`），都挂在
  `lib.hm.dag.entryBefore [ "linkGeneration" ]`。名字必须不同，否则
  `homeConfigurations.all` 同时加载两个模块时 option 冲突。
- `gtk.css` 不在通用删除表里：Hyprland 侧做定向清理，只删软链或内容仍含
  `noctalia.css` 的文件，避免误删 Caelestia 已生成的可用文件。

- [ ] **Step 1: 建 `lib/theme-residue.nix`**

```nix
{ configHome, dataHome }:
let
  cfg = p: "${configHome}/${p}";
  data = p: "${dataHome}/${p}";
in {
  # Hyprland 档案删除：Noctalia 运行时产物。gtk.css 不在这里：
  # 它由 home/hyprland-theme.nix 定向删除（仅软链/含 noctalia.css 的文件）。
  noctaliaArtifacts = [
    (cfg "gtk-3.0/noctalia.css")
    (cfg "gtk-3.0/noctalia-extensions.css")
    (cfg "gtk-4.0/noctalia.css")
    (cfg "gtk-4.0/noctalia-extensions.css")
    (cfg "qt5ct/colors/noctalia.conf")
    (cfg "qt6ct/colors/noctalia.conf")
    (cfg "btop/themes/noctalia.theme")
    (cfg "cava/themes/noctalia")
    (cfg "ghostty/themes/noctalia")
    (cfg "niri/noctalia.kdl")
  ];

  # Caelestia 在 Hyprland 上主动产出、niri 必须删除的文件。
  # 不含 scheme.json / wallpaper / sequences.txt：那是用户状态，删了会丢方案。
  caelestiaRuntimeArtifacts = [
    (cfg "hypr/scheme/current.conf")
    (cfg "hypr/scheme/current.lua")
    (cfg "btop/themes/caelestia.theme")
    (cfg "cava/themes/caelestia")
    (cfg "ghostty/themes/caelestia")
    (cfg "gtk-3.0/thunar.css")
    (cfg "gtk-4.0/thunar.css")
  ];

  # cli.json 里已关闭的生产者留下的产物：两个档案都要删。
  caelestiaDisabledArtifacts = [
    (cfg "htop/htoprc")
    (cfg "fuzzel/fuzzel.ini")
    (cfg "nvtop/nvtop.colors")
    (cfg "qtengine/caelestia.colors")
    (cfg "qtengine/config.json")
    (cfg "spicetify/Themes/caelestia/color.ini")
    (cfg "Equicord/themes/caelestia.theme.css")
    (cfg "Vencord/themes/caelestia.theme.css")
    (cfg "BetterDiscord/themes/caelestia.theme.css")
    (cfg "equibop/themes/caelestia.theme.css")
    (cfg "vesktop/themes/caelestia.theme.css")
    (cfg "legcord/themes/caelestia.theme.css")
    (cfg "zed/themes/caelestia.json")
    (data "PandoraLauncher/themes/caelestia.json")
    (data "warp-terminal/themes/caelestia.yaml")
  ];

  # 旧代遗留、ghostty 不读的文件（生效的是 config）。
  legacyThemeArtifacts = [
    (cfg "ghostty/config.ghostty")
  ];
}
```

- [ ] **Step 2: 挂 activation**

`home/hyprland-theme.nix`（定向删 gtk.css，只删 niri 的 import/软链）：

```nix
home.activation.themeResidueCleanupHyprland =
  lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    rm -f -- ${lib.escapeShellArgs (
      residue.noctaliaArtifacts
      ++ residue.caelestiaDisabledArtifacts
      ++ residue.legacyThemeArtifacts
    )}
    for v in 3 4; do
      f="${config.xdg.configHome}/gtk-$v.0/gtk.css"
      if [ -L "$f" ] || grep -q 'noctalia.css' "$f" 2>/dev/null; then
        rm -f -- "$f"
      fi
    done
  '';
```

`home/gtk.nix`：

```nix
home.activation.themeResidueCleanupNiri = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
  rm -f -- ${lib.escapeShellArgs (
    residue.caelestiaRuntimeArtifacts
    ++ residue.caelestiaDisabledArtifacts
    ++ residue.legacyThemeArtifacts
  )}
'';
```

两处 `let` 里：

```nix
residue = import ../lib/theme-residue.nix {
  inherit (config.xdg) configHome dataHome;
};
```

两个模块都要加 `config` 参数。

- [ ] **Step 3: `home/cava.nix` 加 force**

```nix
xdg.configFile."cava/config" = {
  source = ./cava-config;
  force = true;
};
```

niri 上 Caelestia 不再写 `cava/config`，但旧会话留下的普通文件必须能被 HM 覆盖。

- [ ] **Step 4: 构建 + 手动造假文件验证**

```bash
nix build .#homeConfigurations.desktop-hyprland.activationPackage --no-link
touch ~/.config/gtk-3.0/noctalia.css ~/.config/htop/htoprc ~/.config/cava/themes/noctalia
home-manager switch --flake .#desktop-hyprland
ls ~/.config/gtk-3.0/noctalia.css ~/.config/htop/htoprc ~/.config/cava/themes/noctalia 2>&1
```
Expected: 三个都 `No such file or directory`。

反向：
```bash
touch ~/.config/gtk-3.0/thunar.css ~/.config/hypr/scheme/current.lua ~/.config/ghostty/themes/caelestia
home-manager switch --flake .#desktop-niri
ls ~/.config/gtk-3.0/thunar.css ~/.config/hypr/scheme/current.lua ~/.config/ghostty/themes/caelestia 2>&1
```
Expected: 三个都不存在。

- [ ] **Step 5: Commit**

```bash
git add lib/theme-residue.nix home/hyprland-theme.nix home/gtk.nix home/cava.nix
git commit -m "feat(theme): 激活时清理对方桌面的运行时主题产物"
```

---

## Task 5: Hyprland 边框跟随 Caelestia 方案

**Files:**
- Modify: `home/hyprland.lua`

**Interfaces:**
- `~/.config/hypr/scheme/current.lua` 由 Caelestia `apply_hypr` 生成，返回 `{ active?, primary, secondary, tertiary, surface, onSurface, ... }` 的 table（键名见 `gen_lua`，全部 scheme 颜色）。
- 读取失败时用 `theme-hyprland.nix` 的静态值兜底。

- [ ] **Step 1: 顶部读取方案表**

```lua
local cfg_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local ok, scheme = pcall(dofile, cfg_home .. "/hypr/scheme/current.lua")
local t = ok and scheme or {
  primary = "649afa", secondary = "8b93f8", tertiary = "9d8fe0",
  outline = "737e9c", surface = "2e3246", onSurface = "d4dcec",
}
local function rgba(c, a) return "rgba(" .. c .. a .. ")" end
```

- [ ] **Step 2: 替换两处 `hl.config` 的颜色**

```lua
col = {
  active_border = { colors = { rgba(t.primary, "ee"), rgba(t.secondary, "ee"), rgba(t.tertiary, "ee") }, angle = 45 },
  inactive_border = rgba(t.outline, "aa"),
},
```

两处 `general` 都改；`decoration.active_border` 用同一组；`decoration.shadow.color` 保持 `0x55000000`。

`borders_plus_plus` 的玻璃层保持现有值，不动：

```lua
col = { border_1 = "rgba(ffffff2e)"; border_2 = "rgba(ffffff14)"; };
```

- [ ] **Step 3: 验证**

```bash
caelestia scheme set -m dark
hyprctl reload
hyprctl getoption general:col.active_border
hyprctl getoption general:col.inactive_border
caelestia scheme set -m light
hyprctl reload
hyprctl getoption general:col.active_border
```
Expected: 两次输出不同，且十六进制与 `caelestia scheme get` 的 `primary` / `outline` 一致。

- [ ] **Step 4: Commit**

```bash
git add home/hyprland.lua
git commit -m "feat(hyprland): 边框颜色跟随 Caelestia 壁纸方案"
```

---

## Task 6: 注释与往返回归

**Files:**
- Modify: `flake.nix`、`system/theme.nix`、`system/theme-hyprland.nix`、`home/themes.nix`、`home/hyprland-theme.nix`

- [ ] **Step 1: 在每个文件头写“主题归属”**

一行格式：`主题归属：<路径>（写入者：<模块/Noctalia/Caelestia>）`。`theme-hyprland.nix` 注明“静态兜底 + fastfetch/zathura/mpv/fzf/bat；运行期应用主题由 Caelestia 接管”。

- [ ] **Step 2: 四配置构建**

```bash
nix build .#homeConfigurations.desktop-niri.activationPackage --no-link
nix build .#homeConfigurations.desktop-hyprland.activationPackage --no-link
nixos-rebuild build --flake .#desktop-niri
nixos-rebuild build --flake .#desktop-hyprland
```

- [ ] **Step 3: 两次往返**

```bash
sudo nixos-rebuild switch --flake .#desktop-hyprland   # 登录，检查 A
sudo nixos-rebuild switch --flake .#desktop-niri       # 登录，检查 B
sudo nixos-rebuild switch --flake .#desktop-hyprland   # 登录，检查 A
```

检查 A：
```bash
rg -l noctalia ~/.config/gtk-3.0 ~/.config/gtk-4.0 ~/.config/qt5ct ~/.config/qt6ct ~/.config/cava ~/.config/btop ~/.config/ghostty
# 无输出
test ! -e ~/.config/htop/htoprc && test ! -e ~/.config/fuzzel/fuzzel.ini
dconf read /org/gnome/desktop/interface/gtk-theme     # 跟随当前 mode
caelestia scheme get -m                                # 与 dconf 的 color-scheme 一致
head -1 ~/.config/ghostty/themes/caelestia             # background 与 scheme.json 一致
```

检查 B：
```bash
rg -l caelestia ~/.config/hypr/scheme ~/.config/qtengine ~/.config/zed/themes ~/.config/ghostty/themes ~/.config/cava/themes 2>/dev/null
# 无输出
cat ~/.config/gtk-3.0/gtk.css                          # @import url("noctalia.css");
```

- [ ] **Step 4: Commit**

```bash
git add flake.nix system/theme.nix system/theme-hyprland.nix home/themes.nix home/hyprland-theme.nix
git commit -m "docs(theme): 标注每个主题文件的写入者"
```

---

## Review Focus

1. **浅色模式 GTK**：Caelestia `apply_gtk` 写死 `adw-gtk3-dark`；postHook 必须在它之后写 `adw-gtk3`。测试在 Task 1 Step 4 与 Task 6 检查 A。
2. **postHook 失败不阻塞 Caelestia**：`subprocess.run` 忽略退出码，但半写的主题文件会留在磁盘；脚本用临时文件 + `mv` 原子替换。测试：`caelestia scheme set` 后 `ghostty -e true` 不报主题解析错。
3. **HM 激活期无用户总线**：`dconf write` 可能失败；脚本全部 `|| true`，但 `settings.ini` 必须写成。测试：Task 3 Step 4 的 `gtk-theme-name`。
4. **首次 Hyprland 启动 `current.lua` 不存在**：`hyprland.lua` 必须 `pcall` 兜底，否则配置解析失败。测试：删除该文件后 `hyprctl reload` 仍成功。
5. **清场误删用户状态**：`scheme.json`、wallpaper、`sequences.txt` 不在删除表；测试 Task 4 后 `caelestia scheme get` 不变。

## 不做

- 不拆 HOME、不改 `XDG_CONFIG_HOME`。
- 不给 Caelestia 打补丁或注入自定义 scheme；深浅色由壁纸方案决定。
- 不把 `fastfetch/zathura/mpv/fzf/bat` 接入运行时取色。
- 不动光标、字体、图标值；图标固定 Tela。
