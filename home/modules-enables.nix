# --- 开关面板 ---
# 用户层唯一软件开关：一个布尔一个模块。
#   true  = 安装（包 + 配置）
#   false = 源码保留在仓库里，但不加载
# 键名必须与 home/ 下的 <名字>.nix 完全一致（双向校验见 home/default.nix）。
{
  enable = {
    btop = true;
    caelestia = false;  # Caelestia Shell（hyprland 档案启用；niri 用 noctalia）
    cava = true;
    cli-tools = true;
    clipboard = false; # clipse 剪贴板历史（hyprland 档案启用；niri 用 noctalia 剪贴板）
    cursor-theme = true;
    distrobox = true;
    fastfetch = true;
    flatpak = true;
    ghostty = true;
    git = true;
    gtk = true;         # niri 的 GTK 外观（adw-gtk3 + 玻璃底色）；hyprland 档案关闭
    hyprland = false;   # Hyprland 用户层配置（hyprland 档案启用）
    hyprland-theme = false; # Hyprland 主题选择（主题文件归 Caelestia，这里只选 caelestia）
    mpv = true;
    niri = true;        # niri 用户层配置（工作环境）
    noctalia = true;    # noctalia 桌面外壳 v5（bar/启动器/通知/OSD/托盘/剪贴板/锁屏/壁纸/polkit）
    nvim = true;
    pkgs = true;
    shell = true;
    starship = true;
    swayimg = true;
    themes = true;
    vscodium = true;
    yazi = true;
    zathura = true;
    x11 = true;
    xdg = true;
  };
}
