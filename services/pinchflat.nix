{ config, pkgs-unstable, ...}:
let
  mediaTarget = "/storage/pinchflat";
in
{
  systemd.tmpfiles.rules = [
    # "L /pinchflat - - - - /var/lib/pinchflat"
    "d ${mediaTarget} 0770 pinchflat storage"
  ];


  users.users.pinchflat = {
    # group = "storage";
    isSystemUser = true;
  };

  services.pinchflat = {
    enable = true;
    package = pkgs-unstable.pinchflat;
    openFirewall = true;
    secretsFile = ./../secrets/pinchflat.txt;
    selfhosted = true;
    mediaDir = mediaTarget;
    user = "pinchflat";
    group = "storage";
  };
}
