{ config, pkgs, ... }:
{
# Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;

    # 2. 配置输入法引擎和外观插件
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons     # 核心：内置了拼音、五笔等中文输入法
      fcitx5-mellow-themes     # 皮肤：非常好看的 Material 质感配色主题
    ];
  };

  # 3. 环境变量优化（防止某些老旧或特殊架构软件无法切出输入法）
  environment.variables = {
    XMODIFIERS = "@im=fcitx";
    QT_IM_MODULE = "fcitx";     # 现代 Kitty/Ghostty 终端在 Wayland 下推荐的形式
  };
}
