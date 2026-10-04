{ config, hostname, ...}:
{
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # 借鉴 koru：默认拒绝所有入站，只放行 SSH。
  # clash TUN 是出站方向不受影响；局域网服务以后开哪个端口再放行哪个。
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };
}
