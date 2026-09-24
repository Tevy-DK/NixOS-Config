{ config, pkgs, ... }:
{
  # Enable CUPS to print documents.
    services.printing.enable = true;

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
  services.displayManager.ly.enable = true;
  services.flatpak.enable = true;
  services.gnome.gnome-keyring.enable = true;
}
