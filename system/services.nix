{ config, pkgs, ... }:
{
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };
    services.openssh = {
    enable = true;
    
    # 2. 安全设置
    settings = {
      PermitRootLogin = "no";        # 严格禁止 root 用户直接通过 SSH 登录
      PasswordAuthentication = true;
    };
  };
  services.udisks2.enable = true;

  # 登录管理器 = noctalia-greeter（原 ly 已移除），配置在 ./greeter.nix
  services.flatpak.enable = true;
  services.gnome.gnome-keyring.enable = true;
}
