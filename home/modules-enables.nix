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
    clipboard = true;   # clipse 剪贴板历史；仅 hyprland 档案加载（Mod+V），niri 档案在 flake.nix 里覆盖为 false（noctalia 自带剪贴板面板）
    cursor-theme = true;
    fastfetch = true;
    ghostty = true;
    git = true;
    gtk = true;         # niri 的 GTK 外观（adw-gtk3 + 玻璃底色）；hyprland 档案在 flake.nix 里覆盖为 false（GTK 交给 caelestia）
    hyprland = false;   # Hyprland 用户层配置
    niri = true;        # niri 用户层配置（工作环境）
    noctalia = true;    # noctalia 桌面外壳 v5（bar/启动器/通知/OSD/托盘/剪贴板/锁屏/壁纸/polkit），仅 niri 档案启用
    nvim = true;
    pkgs = true;
    shell = true;
    starship = true;
    sysmenu = false;    # Omarchy 式 fzf 管理中心，源码保留停用
    themes = true;
    vscodium = true;
    yazi = true;
    zathura = true;
  };
}
