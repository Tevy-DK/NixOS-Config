# --- fastfetch ---
# 系统信息卡片：开机仪表盘左半列（借鉴 koru 的卡片式布局）。
# 无 logo、纯文本卡片，配色来自全局 theme.nix；虚拟机去掉亮度/电池项。
{ theme, ... }:
let
  # 与 CPU 行对齐的 66 列分隔线
  separatorDashes = builtins.concatStringsSep "" (builtins.genList (_: "-") 66);
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      display = {
        separator = "  ";
        key.width = 12;
      };

      modules = [
        {
          type = "title";
          format = "{#3}{user-name}{#} @ {#2}{host-name}{#}";
          keyColor = theme.accent-2;
          outputColor = theme.fg;
        }
        {
          type = "custom";
          format = "{#2}${separatorDashes}{#}";
        }
        {
          type = "os";
          key = "OS";
          keyColor = theme.accent;
          outputColor = theme.fg;
        }
        {
          type = "kernel";
          key = "Kernel";
          keyColor = theme.accent;
          outputColor = theme.fg;
        }
        {
          type = "uptime";
          key = "Uptime";
          keyColor = theme.accent;
          outputColor = theme.fg;
        }
        {
          type = "packages";
          key = "Packages";
          keyColor = theme.accent-2;
          outputColor = theme.fg;
        }
        {
          type = "shell";
          key = "Shell";
          keyColor = theme.accent-2;
          outputColor = theme.fg;
        }
        {
          type = "cpu";
          key = "CPU";
          keyColor = theme.ansi.cyan;
          outputColor = theme.fg;
        }
        {
          type = "memory";
          key = "Memory";
          keyColor = theme.ansi.cyan;
          outputColor = theme.fg;
        }
        {
          type = "disk";
          key = "Disk";
          keyColor = theme.ansi.cyan;
          outputColor = theme.fg;
        }
        {
          type = "localip";
          key = "Network";
          keyColor = theme.ansi.cyan;
          outputColor = theme.fg;
        }
        {
          type = "custom";
          format = "{#2}${separatorDashes}{#}";
        }
        {
          type = "colors";
          symbol = "circle";
          keyColor = theme.muted;
        }
      ];
    };
  };
}
