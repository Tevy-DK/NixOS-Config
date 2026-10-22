{ config, pkgs, lib, ... }:

{
  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true;    # KMS 必需,只生成一个 wrapper,不碰内核
    openFirewall = true;   # 别手写端口
  };

  users.users.dk.extraGroups = [ "uinput" ];
}
