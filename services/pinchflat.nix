{ ... }:
let
  mediaTarget = "/storage/pinchflat";
in
{
  systemd.tmpfiles.rules = [
    "d ${mediaTarget} 0770 pinchflat storage"
  ];

  users.users.pinchflat = {
    isSystemUser = true;
  };

  services.pinchflat = {
    enable = true;
    openFirewall = true;
    port = 8945;
    secretsFile = ./../secrets/pinchflat.txt;
    selfhosted = true;
    mediaDir = mediaTarget;
    user = "pinchflat";
    group = "storage";
  };
}
