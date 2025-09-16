# Nixos-Config
Nixos Configuration for Equipment Deployments


## `micboard`
This deployment include docker running micboard through an OCI container.    
There are stateful partitions (disko mac-mini.nix) for docker and micboard states. All data not in this location is in tmpfs.
