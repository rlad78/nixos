{
  config,
  lib,
  hosts,
  util,
  ...
}:
let
  cfg = config.arf.snootflix;

  mediaUserCfg = {
    isSystemUser = true;
    group = "media";
  };

  # the math works here, don't question it c:
  download-speed = cfg.bandwidth.downMegabits * 10 * cfg.bandwidth.torrentDownPercentage;
  upload-speed = cfg.bandwidth.upMegabits * 10 * cfg.bandwidth.torrentUpPercentage;
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
    user = "transmission";
    group = "media";
    openFirewall = true;
    openRPCPort = true;
    openPeerPorts = true;
    settings = {
      download-dir = "${cfg.mediaRootDir}/torrents/manual";
      incomplete-dir = "${cfg.mediaRootDir}/torrents/.incomplete";
      incomplete-dir-enabled = true;

      speed-limit-down = download-speed;
      speed-limit-down-enabled = true;
      speed-limit-up = upload-speed;
      speed-limit-up-enabled = true;

      trash-original-torrent-files = true;

      rpc-whitelist = (lib.strings.join "," (util.gatherAllHostIPs hosts)) + ",127.0.0.1";
      rpc-host-whitelist-enabled = false;
      rpc-bind-address = "0.0.0.0";
    };
  };
}
