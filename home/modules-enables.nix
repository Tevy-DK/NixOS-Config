# --- 开关面板 ---
# 用户层唯一软件开关：一个布尔一个模块。
#   true  = 安装（包 + 配置）
#   false = 源码保留在仓库里，但不加载
# 键名必须与 home/ 下的 <名字>.nix 完全一致（双向校验见 home/default.nix）。
{
  enable = {
    btop = true;
    caelestia = false;  # caelestia-shell（Hyprland 娱乐环境；flake.nix 按机器的 desktop 字段覆盖下面三项）
    cava = true;
    cli-tools = true;
    clipboard = true;
    cursor-theme = true;
    fastfetch = true;
    ghostty = true;
    git = true;
    gtk = true;         # niri 的 GTK 外观（adw-gtk3 + 方角描边）；hyprland 档案在 flake.nix 里覆盖为 false（GTK 交给 caelestia）
    hyprland = false;   # Hyprland 用户层配置
    launcher = true;    # fuzzel 启动器；hyprland 档案在 flake.nix 里覆盖为 false（用 caelestia 自带启动器）
    niri = true;        # niri 用户层配置（工作环境）
    nvim = true;
    pkgs = true;
    powermenu = true;   # TUI 电源菜单（关机/重启/登出），Mod+X 浮窗
    shell = true;
    starship = true;
    sysmenu = true;
    themes = true;
    vscodium = true;
    yazi = true;
    zathura = true;
  };
}
