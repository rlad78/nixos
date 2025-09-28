{ config , ...}:
{
  systemd.tmpfiles.rules = [
    "L /pinchflat - - - - /var/lib/pinchflat"
  ];

  services.pinchflat = {
    enable = true;
    openFirewall = true;
    secretsFile = ./../secrets/pinchflat.txt;
    selfhosted = true;
  };
}
