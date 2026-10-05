# --- btop ---
# 系统监控：主题由全局 theme.nix 生成（借鉴 koru 的做法）。
# 盒子边框（cpu/mem/net/proc + div_line）统一用弱化的 muted-alt。
{ theme, ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "dk-mocha";
      theme_background = false;
      truecolor = true;
      rounded_corners = true;
      graph_symbol = "braille";
      update_ms = 2000;
    };
    themes.dk-mocha = ''
      # DK Mocha —— Koru Fern 绿系 btop 主题，由 system/theme.nix 生成

      # Main bg
      theme[main_bg]="${theme.bg}"

      # Main text color
      theme[main_fg]="${theme.fg}"

      # Title color for boxes (purple accent)
      theme[title]="${theme.accent-2}"

      # Highlight color for keyboard shortcuts
      theme[hi_fg]="${theme.accent-bright}"

      # Background color of selected item in processes box
      theme[selected_bg]="${theme.bg-alt}"

      # Foreground color of selected item in processes box
      theme[selected_fg]="${theme.fg}"

      # Color of inactive/disabled text
      theme[inactive_fg]="${theme.muted-alt}"

      # Misc colors for processes box (green accent)
      theme[proc_misc]="${theme.ansi-bright.green}"

      # All borders use the same color
      theme[cpu_box]="${theme.muted-alt}"
      theme[mem_box]="${theme.muted-alt}"
      theme[net_box]="${theme.muted-alt}"
      theme[proc_box]="${theme.muted-alt}"

      # Box divider line and small boxes line color
      theme[div_line]="${theme.muted-alt}"

      # Temperature graph colors
      theme[temp_start]="${theme.accent-deep}"
      theme[temp_mid]="${theme.accent}"
      theme[temp_end]="${theme.ansi.red}"

      # CPU graph colors
      theme[cpu_start]="${theme.accent-deep}"
      theme[cpu_mid]="${theme.ansi.red}"
      theme[cpu_end]="${theme.fg}"

      # Mem/Disk free meter
      theme[free_start]="${theme.black}"
      theme[free_mid]="${theme.muted-alt}"
      theme[free_end]="${theme.accent-deep}"

      # Mem/Disk cached meter
      theme[cached_start]="${theme.black}"
      theme[cached_mid]="${theme.muted-alt}"
      theme[cached_end]="${theme.accent}"

      # Mem/Disk available meter (green: available space reads as "good")
      theme[available_start]="${theme.black}"
      theme[available_mid]="${theme.ansi.green}"
      theme[available_end]="${theme.ansi-bright.green}"

      # Mem/Disk used meter
      theme[used_start]="${theme.accent-deep}"
      theme[used_mid]="${theme.ansi.red}"
      theme[used_end]="${theme.fg}"

      # Download graph colors (green: incoming data)
      theme[download_start]="${theme.black}"
      theme[download_mid]="${theme.ansi.green}"
      theme[download_end]="${theme.ansi-bright.green}"

      # Upload graph colors
      theme[upload_start]="${theme.black}"
      theme[upload_mid]="${theme.muted-alt}"
      theme[upload_end]="${theme.accent}"
    '';
  };
}
