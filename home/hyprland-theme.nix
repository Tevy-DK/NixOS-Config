# --- Hyprland 桌面外观（静态主题）---
# Caelestia Shell 只负责自己的面板，不像 Noctalia 那样把壁纸调色板分发给
# btop/cava/ghostty。Hyprland 档案因此继续用 system/theme-hyprland.nix 的
# 静态色值，在这里覆盖共享模块里以 Noctalia 为主题的那几项。
#
# 覆盖全部走 mkForce：niri 档案不加载本模块，产物与引入 Hyprland 前逐字节相同。
{ lib, theme, ... }:
let
  hex = c: lib.toLower (lib.removePrefix "#" c);
in
{
  # btop：共享的 home/btop.nix 只声明 color_theme = "noctalia"，
  # 主题文件由 Noctalia 运行时生成；Hyprland 侧自带一份静态主题。
  programs.btop = {
    settings.color_theme = lib.mkForce "nix-periwinkle";
    themes.nix-periwinkle = ''
      # btop —— Nix Periwinkle，色值唯一来源 system/theme-hyprland.nix

      theme[main_bg]="${theme.bg}"
      theme[main_fg]="${theme.fg}"
      theme[title]="${theme.accent-2}"
      theme[hi_fg]="${theme.accent-bright}"
      theme[selected_bg]="${theme.bg-alt}"
      theme[selected_fg]="${theme.fg}"
      theme[inactive_fg]="${theme.muted-alt}"
      theme[proc_misc]="${theme.ansi-bright.green}"

      theme[cpu_box]="${theme.muted-alt}"
      theme[mem_box]="${theme.muted-alt}"
      theme[net_box]="${theme.muted-alt}"
      theme[proc_box]="${theme.muted-alt}"
      theme[div_line]="${theme.muted-alt}"

      theme[temp_start]="${theme.accent-deep}"
      theme[temp_mid]="${theme.accent}"
      theme[temp_end]="${theme.ansi.red}"

      theme[cpu_start]="${theme.accent-deep}"
      theme[cpu_mid]="${theme.ansi.red}"
      theme[cpu_end]="${theme.fg}"

      theme[free_start]="${theme.black}"
      theme[free_mid]="${theme.muted-alt}"
      theme[free_end]="${theme.accent-deep}"

      theme[cached_start]="${theme.black}"
      theme[cached_mid]="${theme.muted-alt}"
      theme[cached_end]="${theme.accent}"

      theme[available_start]="${theme.black}"
      theme[available_mid]="${theme.ansi.green}"
      theme[available_end]="${theme.ansi-bright.green}"

      theme[used_start]="${theme.accent-deep}"
      theme[used_mid]="${theme.ansi.red}"
      theme[used_end]="${theme.fg}"

      theme[download_start]="${theme.black}"
      theme[download_mid]="${theme.ansi.green}"
      theme[download_end]="${theme.ansi-bright.green}"

      theme[upload_start]="${theme.black}"
      theme[upload_mid]="${theme.muted-alt}"
      theme[upload_end]="${theme.accent}"
    '';
  };

  # ghostty：共享的 home/ghostty.nix 指向 Noctalia 运行时生成的主题。
  # 这里把选择切到 HM 自己管理的 Nix-Periwinkle，并补一份同名主题文件；
  # 其余窗口/键位/字体设置继续沿用共享模块。
  programs.ghostty.settings.theme = lib.mkForce "Nix-Periwinkle";
  programs.ghostty.themes.Nix-Periwinkle = {
    background = hex theme.bg;
    foreground = hex theme.fg;
    cursor-color = hex theme.cursor;
    selection-background = hex theme.accent-bg;
    selection-foreground = hex theme.fg;
    palette = [
      "0=${theme.ansi.black}"    "1=${theme.ansi.red}"     "2=${theme.ansi.green}"   "3=${theme.ansi.yellow}"
      "4=${theme.ansi.blue}"     "5=${theme.ansi.magenta}" "6=${theme.ansi.cyan}"    "7=${theme.ansi.white}"
      "8=${theme.ansi-bright.black}"  "9=${theme.ansi-bright.red}"    "10=${theme.ansi-bright.green}" "11=${theme.ansi-bright.yellow}"
      "12=${theme.ansi-bright.blue}"  "13=${theme.ansi-bright.magenta}" "14=${theme.ansi-bright.cyan}" "15=${theme.ansi-bright.white}"
    ];
  };

  # cava：共享的 home/cava.nix 指向 Noctalia 的运行时主题文件。
  # Hyprland 侧用同一份配置，只把 [color] 的 theme 行换成静态主题。
  xdg.configFile."cava/config" = lib.mkForce {
    text = builtins.replaceStrings
      [ ''theme = "noctalia"'' ]
      [ ''theme = "nix-periwinkle"'' ]
      (builtins.readFile ./cava-config);
  };

  xdg.configFile."cava/themes/nix-periwinkle".text = ''
    [color]
    background = '${theme.bg}'
    foreground = '${theme.fg}'
    gradient = 1
    gradient_count = 3
    gradient_color_1 = '${theme.accent-deep}'
    gradient_color_2 = '${theme.accent}'
    gradient_color_3 = '${theme.accent-bright}'
  '';
}
