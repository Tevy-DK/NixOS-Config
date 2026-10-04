{ config, lib, ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirror.nju.edu.cn/nix-channels/store"
    "https://cache.nixos.org"
    "https://yazi.cachix.org"
    ];
    trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
    ];
  };

  # 借鉴 koru：每天凌晨清理 7 天前的旧代，防止 store 无限膨胀
  nix.gc = {
    automatic = true;
    dates = "03:15";
    options = "--delete-older-than 7d";
  };
}
