{ config, pkgs, ... }:
{
  # 启用 cliphist 服务
  services.cliphist = {
    enable = true;
    # 可选：允许存储图片到历史记录（默认为 true）[reference:2]
    # allowImages = true;
    # 可选：自定义 cliphist 命令参数[reference:3]
    # extraOptions = [ "-max-items" "1000" ];
  };

  # 确保 wl-clipboard 已安装（services.cliphist 会自动处理）
  # 但如果需要，也可以显式声明
  # home.packages = with pkgs; [ wl-clipboard ];
}
