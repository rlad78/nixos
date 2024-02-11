{ configs, pkgs, ... }:
{
  # make dir for mounting things on the fly
  systemd.tmpfiles.rules = [
    "d /mnt 0770 root root"
  ];
}
