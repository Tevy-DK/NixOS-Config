# --- 开关面板 ---
# 用户层唯一软件开关：一个布尔一个模块。
#   true  = 安装（包 + 配置）
#   false = 源码保留在仓库里，但不加载
# 键名必须与 home/ 下的 <名字>.nix 完全一致（双向校验见 home/default.nix）。
{
  enable = {
    btop = true;
    cava = true;
    cli-tools = true;
    cursor-theme = true;
    fastfetch = true;
    ghostty = true;
    git = true;
    gtk = true;         # GTK 外观（adw-gtk3 + 玻璃底色）
    niri = true;        # niri 用户层配置（工作环境）
    noctalia = true;    # noctalia 桌面外壳 v5（bar/启动器/通知/OSD/托盘/剪贴板/锁屏/壁纸/polkit）
    nvim = true;
    pkgs = true;
    shell = true;
    starship = true;
    themes = true;
    vscodium = true;
    yazi = true;
    zathura = true;
    xdg = true;
  };
}
