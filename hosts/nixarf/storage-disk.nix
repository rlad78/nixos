{ config, lib, pkgs, modulesPath, ... }:

{
  # STORAGE DISKS
  users.groups.storage.members = [ "richard" "syncthing" ];
  
  ## 1TB spinning rust
  systemd.tmpfiles.rules = [ "d /storage 0775 root storage" ];
  fileSystems."/storage" =
    { device = "/dev/disk/by-uuid/0082b0dd-ef0c-4928-84d6-f9206600aa4b";
      fsType = "ext4";
    };
}
