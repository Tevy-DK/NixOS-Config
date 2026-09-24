{
  description = "DogKing's flake settings";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
    };
  };

  outputs = { self, nixpkgs, home-manager, noctalia, ... }@inputs: {
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
