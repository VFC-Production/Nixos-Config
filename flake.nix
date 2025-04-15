{
  description = "nix-config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11-small";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    disko-images.url = "github:chrillefkr/disko-images";

  };

  outputs = {
    self,
    nixpkgs,
    impermanence,
    disko,
    disko-images,
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
    nixosConfigurations = {
      micboard = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
            disko.nixosModules.disko
            disko-images.nixosModules.disko-images
            ./base-config/mac-mini.nix # Base system config. Meant to be extended with below lines.
            ./disk-config/mac-mini.nix # Declare disk mounts and boot config.
            ./service-config/docker/containerd.nix # Configure docker daemon.
            ./service-config/docker/micboard.nix # Run Micboard with docker via systemd.
            ./service-config/UI/micboard-kiosk.nix # Run a basic Cage session with epiphany. Allows micboard to just be the mac and a display.
        ];
      };
    };
  };
}
