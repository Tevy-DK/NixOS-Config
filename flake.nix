{
  description = "DogKing's flake settings";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-cli = {
      url = "github:caelestia-dots/cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.56.0";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-scroll-overview = {
      url = "github:yayuuu/hyprland-scroll-overview";
      inputs.hyprland.follows = "hyprland";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = { self, nixpkgs, home-manager, hyprland , ... }@inputs: {
    overlays.default = final: prev: {
      yaziPlugins = prev.yaziPlugins // {
        mount = prev.yaziPlugins.mount.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            substituteInPlace mount.yazi/cross.lua \
              --replace-fail '"--no-user-interaction"' ""
          '';
        });
       };
    };
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
	  nixpkgs.overlays = [
      	    self.overlays.default
          ];
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users."dk" = import ./home-manager/home.nix;
        }
      ];
    };
  };
}
