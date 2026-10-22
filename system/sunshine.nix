{ config, pkgs, lib, ... }:

{
  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;    # KMS 必需,只生成一个 wrapper,不碰内核
    openFirewall = true;   # 别手写端口
  };

  # 新增这段：显式地使用新语法配置 Avahi，以覆盖 Sunshine 的旧版默认设置
  services.avahi = {
    enable = true;
    settings.publish = {
      "disable-publishing" = false;              # 对应旧 publish.enable = true
      "disable-user-service-publishing" = false; # 对应旧 publish.userServices = true
      "publish-addresses" = true;                # 确保地址记录被发布
    };
  };

  users.users.dk.extraGroups = [ "uinput" ];
}
