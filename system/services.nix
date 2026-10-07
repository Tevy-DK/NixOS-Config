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
  # 登录页黑洞动画：官方社区仓库的 .dur 动画（一颗行星被黑洞吞噬）
  # https://codeberg.org/fairyglade/ly-community/src/branch/main/animations/dur
  # 240x67 正好是一整屏 1080p TTY 默认字体；分辨率不同则居中显示，多余部分留黑
  services.displayManager.ly.settings = {
    animation = "dur_file";
    dur_file_path = "/etc/ly/blackhole-smooth-240x67.dur";
    dur_offset_alignment = "center";
  };
  environment.etc."ly/blackhole-smooth-240x67.dur".source = ./ly/blackhole-smooth-240x67.dur;
  services.flatpak.enable = true;
  services.gnome.gnome-keyring.enable = true;
}
