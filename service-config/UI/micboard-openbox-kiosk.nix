{ pkgs, lib, ... }:

let
  kioskUsername = "user";
  browser = pkgs.firefox;
  autostart = ''
    #!${pkgs.bash}/bin/bash
    # End all lines with '&' to not halt startup script execution

    # https://developer.mozilla.org/en-US/docs/Mozilla/Command_Line_Options
    sleep 5 && firefox --kiosk http://localhost:8058/ &
    unclutter -idle 0 &
  '';

  inherit (pkgs) writeScript;
in {
  environment.systemPackages = [ pkgs.firefox pkgs.unclutter ];
  boot.kernelParams = [ "quiet" ];
  boot.loader.timeout = lib.mkForce 1;
  boot.plymouth.enable = true;

  # Configure X11
  services.xserver = {
    enable = true;
    layout = "us"; # keyboard layout
    libinput.enable = true;

    # Let lightdm handle autologin
    displayManager.lightdm = {
      enable = true;
      autoLogin = {
        enable = true;
        timeout = 0;
        user = kioskUsername;
      };
    };

    # Start openbox after autologin
    windowManager.openbox.enable = true;
    displayManager.defaultSession = "none+openbox";
  };

  # Overlay to set custom autostart script for openbox
  nixpkgs.overlays = with pkgs; [
    (self: super: {
      openbox = super.openbox.overrideAttrs (oldAttrs: rec {
        postFixup = ''
          ln -sf /etc/openbox/autostart $out/etc/xdg/openbox/autostart
        '';
      });
    })
  ];

  # By defining the script source outside of the overlay, we don't have to
  # rebuild the package every time we change the startup script.
  environment.etc."openbox/autostart".source = writeScript "autostart" autostart;
}
