{ outputs, inputs, lib, config, pkgs, modulesPath, ... }:{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
    ];

  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";


  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "24.11";
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
