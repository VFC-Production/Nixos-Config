{
  description = "nix-config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";

  };

  outputs = {
    self,
    nixpkgs,
    impermanence,
    disko,
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
            ({ config, ... }: {
              # shut up state version warning
              nixpkgs.system = "x86_64-linux";
              system.stateVersion = config.system.nixos.version;
              # Adjust this to your liking.
              # WARNING: if you set a too low value the image might be not big enough to contain the nixos installation
            })
            disko.nixosModules.disko
            ({ config, ... }: {
              # shut up state version warning
              system.stateVersion = config.system.nixos.version;
              # Adjust this to your liking.
              # WARNING: if you set a too low value the image might be not big enough to contain the nixos installation
              disko.devices.disk.main.imageSize = "10G";
            })
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
