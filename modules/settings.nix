{ config, lib, ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirror.nju.edu.cn/nix-channels/store"
    "https://cache.nixos.org"
    "https://noctalia.cachix.org"
    "https://yazi.cachix.org"
    ];
    trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
    ];
  };
}
