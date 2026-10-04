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
    gtk = true;
    hyprland = false;   # Hyprland 用户层配置
    launcher = true;
    niri = true;        # niri 用户层配置（工作环境）
    nvim = true;
    pkgs = true;
    shell = true;
    starship = true;
    sysmenu = true;
    themes = true;
    vscodium = true;
    yazi = true;
    zathura = true;
  };
}
