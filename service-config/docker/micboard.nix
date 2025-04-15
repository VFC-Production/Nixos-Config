{ config, pkgs, ... }:

{
  config.virtualisation.oci-containers.containers = {
    micboard = {
      image = "ghcr.io/karlcswanson/micboard:0.8.7-updates"; # Container Image.
      #ports = ["0.0.0.0:8058:8058"]; # Expose 8058 on all interfaces, 0.0.0.0, and _not_ 127.0.0.1
      volumes = [ # Mount config so state persists reboots
        "/system-data/serviceState/:/root/.local/share/micboard"
      ];
      extraOptions = [ "--network=host" ]; #Just let the container access host ports. Probably need this to pick up telemetry anyways.
    };
  };
}
