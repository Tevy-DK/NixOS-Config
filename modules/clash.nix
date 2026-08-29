{ config, pkgs, ... }:
{
  programs.clash-verge = {
    enable = true;
    tunMode = true;        # 启用 TUN 模式
    serviceMode = true;    # 通常建议同时启用服务模式
    autoStart = false;      # 可选：开机自启
  };
}
