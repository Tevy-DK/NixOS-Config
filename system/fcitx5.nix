# 系统层：Fcitx5 输入法框架 + 中文拼音（时区/地区在 hosts/<名字>/locale.nix）
#
# Wayland + XWayland 混合会话的环境变量策略（参考 fcitx5 wiki）：
#   - XMODIFIERS 两个世界都需要；X11 应用靠 XIM 连到 fcitx5 的 XIM server。
#   - 不设 GTK_IM_MODULE：Wayland 下让 GTK 走 text-input-v3；X11 下由
#     ~/.config/gtk-{2,3,4}.0 的 gtk-im-module=fcitx 指定（见 home/gtk.nix）。
#     全局设置 GTK_IM_MODULE 还会泄漏进 Flatpak 沙箱，那里没有 fcitx GTK
#     模块，反而会让 GTK 应用失去输入法。
#   - niri 不是 KDE，Qt 的 text-input-v2 不可用：Wayland 和 X11/XCB 的 Qt
#     都显式用 fcitx 模块；Qt5/Qt6 插件路径都要在 QT_PLUGIN_PATH 里。
#   - SDL2 的 X11 后端用 SDL_IM_MODULE=fcitx。
{ pkgs, ... }:

{
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons # 核心：内置拼音等中文输入法
        fcitx5-mellow-themes              # 皮肤：Material 质感配色主题
        fcitx5-gtk                        # 为 GTK 程序提供更好的输入法支持
      ];
      waylandFrontend = true; # 关键配置
    };
  };

  environment.variables = {
    XMODIFIERS = "@im=fcitx";
    QT_IM_MODULE = "fcitx";
    # Qt 6.7+ 的模块回退顺序；打包不完整的 Qt 应用（含 Flatpak）也能落到
    # 原生 Wayland text-input，而不是直接失去输入法。
    QT_IM_MODULES = "wayland;fcitx;ibus";
    SDL_IM_MODULE = "fcitx";
  };

  # with-addons 已经把 fcitx5-qt5 / fcitx5-qt6 一起装进来；NixOS 的 fcitx5
  # 模块只把 Qt6 插件路径放进 QT_PLUGIN_PATH，这里补 Qt5，Qt5 的 XCB 应用
  # 才找得到 QT_IM_MODULE=fcitx 对应的 platforminputcontext。
  environment.variables.QT_PLUGIN_PATH = [
    "${pkgs.libsForQt5.fcitx5-qt}/${pkgs.libsForQt5.qtbase.qtPluginPrefix}"
  ];
}
