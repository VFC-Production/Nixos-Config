
{ outputs, inputs, lib, config, pkgs, modulesPath, ... }:{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix") # Pick up kernel modules/drivers that aren't already under boot.initrd
    ];
  specialisation = {
    runtime = {
      inheritParentConfig = false;
      configuration = {
        networking.networkmanager.enable = true; # NMTUI is dumb easy to use.

          time.timeZone = "America/New_York"; # Set Timezone


          nix = {
        # I've been deploying with flakes
            extraOptions = ''
              experimental-features = nix-command flakes 
            '';
          };

        # Define a user
          users.users = {

            user = {
              isNormalUser = true;
              home = "/home/user";
              description  = "general system user";
              uid = 1000; 
              extraGroups = [ "wheel" "docker" "networkmanager" "storage" ]; 
            };
          };

          system.stateVersion = "24.11";
          boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
          boot.initrd.kernelModules = [ ];
          boot.kernelModules = [ "kvm-intel" ];
          boot.extraModulePackages = [ ];

          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      };
    };
    Maintenance Mode = {
      configuration = {
        services.tailscale.enable = true; #
        users.users.user.hashedPassword = "$y$j9T$gfos6aXIGxx6T9SZXIGft/$CuCPpN0BGI.YGe3qsrnZyMSXgDyP6uIVPpACXsXZyY1"; #  mkpasswd
        systemd.services."cage@".enable = lib.mkForce "false"; # Force Disable Cage UI.
        services.openssh = {
          enable = true;
          ports = [ 22 ];
          settings = {
            PasswordAuthentication = true;
            AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
            UseDns = true;
            X11Forwarding = false;
            PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
          };
        };
      };
    };
  }; 
}
