{ inputs, outputs, lib, pkgs, ... }:{
# Enable Plymouth. Just makes things look pretty.  
  boot.kernelParams = [ "quiet" ];
  boot.loader.timeout = lib.mkForce 0;
  boot.plymouth.enable = true;

# Dbus is a system messaging bus that allows applications to communicate with each other
  services.dbus.enable = true;

# Fonts, icons
  environment.systemPackages = [ pkgs.hicolor-icon-theme ];

  fonts.enableDefaultFonts = true;
  xdg.icons.enable = true;
  gtk.iconCache.enable = true;

# Disable udisks2. Related to mounting and manipulating disks.
  services.udisks2.enable = false;

# Enable OpenGL for Render
  hardware.opengl.enable = true;

# Cage Provides UI for Web to run on 
  systemd.services."cage@" = {
    enable = true;
    after = [ "systemd-user-sessions.service" "dbus.socket" "systemd-logind.service" "getty@%i.service" "plymouth-deactivate.service" "plymouth-quit.service" ];
    before = [ "graphical.target" ];
    wants = [ "dbus.socket" "systemd-logind.service" "plymouth-deactivate.service" ];
    wantedBy = [ "graphical.target" ];
    conflicts = [ "getty@%i.service" ]; # "plymouth-quit.service" "plymouth-quit-wait.service"

    restartIfChanged = false;
    serviceConfig = {
      ExecStart = "${pkgs.cage}/bin/cage -d -- ${pkgs.epiphany}/bin/epiphany 127.0.0.1:8058"; #Just open micboard
      User = "serviceRunner";

      # ConditionPathExists = "/dev/tty0";
      IgnoreSIGPIPE = "no";

      # Log this user with utmp, letting it show up with commands 'w' and
      # 'who'. This is needed since we replace (a)getty.
      UtmpIdentifier = "%I";
      UtmpMode = "user";
      # A virtual terminal is needed.
      TTYPath = "/dev/%I";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";
      # Fail to start if not controlling the virtual terminal.
      StandardInput = "tty-fail";
      StandardOutput = "syslog";
      StandardError = "syslog";
      # Set up a full (custom) user session for the user, required by Cage.
      PAMName = "cage";
    };
  };

# PAM Security Settings
  security.pam.services.cage.text = ''
    auth    required pam_unix.so nullok
    account required pam_unix.so
    session required pam_unix.so
    session required ${pkgs.systemd}/lib/security/pam_systemd.so
  '';

  systemd.targets.graphical.wants = [ "cage@tty1.service" ];

  systemd.defaultUnit = "graphical.target";


}
