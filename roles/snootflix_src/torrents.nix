{
  config,
  ...
}:
let
  cfg = config.arf.snootflix;

  mediaUserCfg = {
    isSystemUser = true;
    group = "media";
  };
in
{
  systemd.tmpfiles.rules = [
    "d ${cfg.stateRootDir}/transmission 0700 transmission media"

    "d ${cfg.mediaRootDir}/torrents 0755 root media"
    "d ${cfg.mediaRootDir}/torrents/radarr 0755 transmission media"
    "d ${cfg.mediaRootDir}/torrents/sonarr 0755 transmission media"
    "d ${cfg.mediaRootDir}/torrents/sonarr-anime 0755 transmission media"
    "d ${cfg.mediaRootDir}/torrents/prowlarr 0755 transmission media"
    "d ${cfg.mediaRootDir}/torrents/manual 0755 transmission media"
    "d ${cfg.mediaRootDir}/torrents/watch 0775 transmission media"
    "d ${cfg.mediaRootDir}/torrents/.incomplete 0755 transmission media"
  ];

  users.users.transmission = mediaUserCfg;
  services.transmission = {
    enable = true;
    home = "${cfg.stateRootDir}/transmission";
    user = "transmission";
    group = "media";
    openFirewall = true;
    openRPCPort = true;
    openPeerPorts = true;
    settings = {
      download-dir = "${cfg.mediaRootDir}/torrents/manual";
      incomplete-dir = "${cfg.mediaRootDir}/torrents/.incomplete";
      incomplete-dir-enabled = true;
      watch-dir = "${cfg.mediaRootDir}/torrents/watch";
      watch-dir-enabled = true;

      speed-limit-down = 37500;
      speed-limit-down-enabled = true;
      speed-limit-up = 37500;
      speed-limit-up-enabled = true;

      trash-original-torrent-files = true;

      rpc-host-whitelist = "snootflix,10.0.0.10";
      rpc-bind-address = "0.0.0.0";
    };
  };
}
