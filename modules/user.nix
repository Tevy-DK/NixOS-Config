{ config, pkgs, ...}:
{
  users.users.dk = {
    isNormalUser = true;
    description = "dk";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };
}