{ config, lib, ... }:
#nix settings
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirror.nju.edu.cn/nix-channels/store"
    "https://cache.nixos.org"
    ];
    trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
}
