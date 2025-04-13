{
  description = "nix-config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11-small";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    mobile-nixos = {
      url = github:pcs3rd/mobile-nixos/Lenovo-kodama;
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    impermanence,
    disko,
    darwin,
    mobile-nixos, 
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {

    homeConfigurations = {
      # FIXME replace with your username@hostname
      "rdean@macair" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main home-manager configuration file <
          ./home-configs/raymond.nix
        ];
      };
    };
    darwinConfigurations = {
      "a2681" = darwin.lib.darwinSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./modules/nix-core.nix
          ./modules/system.nix
          ./modules/apps.nix
          ./modules/host-users.nix
          ./darwin-alacarte/nix-conf.nix
        ];
      };
  };
    nixosConfigurations = {
      kodama = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
            ./alacarte/tailscale.nix
            ./base-configs/kodama.nix
        ];
      };
    };
}
