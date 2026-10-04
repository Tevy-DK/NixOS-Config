# 系统层：Fcitx5 输入法框架 + 中文拼音（时区/地区在 hosts/<名字>/locale.nix）
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
  };
}
