{
  config,
  hosts,
  ...
}:
let
  flake-root-dir = ./../..;
  cfg = config.arf.snootflix;

  mediaUserCfg = {
    isSystemUser = true;
    group = "media";
  };

  bandwidth-megabytes = builtins.ceil (cfg.bandwidth.downMegabits / 8.0);
in
{
  systemd.tmpfiles.rules = [
    "d ${cfg.mediaRootDir}/usenet 0755 root media"
    "d ${cfg.mediaRootDir}/usenet/radarr 0775 sabnzbd media"
    "d ${cfg.mediaRootDir}/usenet/sonarr 0775 sabnzbd media"
    "d ${cfg.mediaRootDir}/usenet/sonarr-anime 0775 sabnzbd media"
    "d ${cfg.mediaRootDir}/usenet/prowlarr 0775 sabnzbd media"
    "d ${cfg.mediaRootDir}/usenet/manual 0775 sabnzbd media"
  ];

  users.users.sabnzbd = mediaUserCfg;
  services.sabnzbd = {
    enable = true;
    group = "media";
    openFirewall = true;
    allowConfigWrite = true;
    secretFiles = [
      (flake-root-dir + "/secrets/sabnzbd_secrets.ini")
      ./sabnzbd_extra.ini
    ];
    settings = {
      misc = {
        host = "0.0.0.0";
        port = 6336;
        host_whitelist =
          "${config.networking.hostName}," + toString (hosts.${config.networking.hostName}.tail-ip);
        bandwidth_max = "${toString bandwidth-megabytes}M";
        bandwidth_perc = cfg.bandwidth.usenetDownPercentage;
        cache_limit = "1G";
        complete_dir = "${cfg.mediaRootDir}/usenet/manual";
        dirscan_dir = "${cfg.mediaRootDir}/usenet/watch";
        download_dir = "${cfg.mediaRootDir}/usenet/.incomplete";
        permissions = "775";
      };
      servers = {
        "sslreader.eweka.nl" = {
          name = "sslreader.eweka.nl";
          displayname = "Eweka";
          host = "sslreader.eweka.nl";
          port = 563;
          timeout = 60;
          connections = 18;
          ssl = true;
          ssl_verify = 2;
          priority = 50;
          expire_date = "2027-11-01";
        };
        "news.newsgroup.ninja" = {
          name = "news.newsgroup.ninja";
          displayname = "Newsgroup Ninja";
          host = "news.newsgroup.ninja";
          port = 563;
          timeout = 60;
          connections = 40;
          ssl = true;
          ssl_verify = 2;
          priority = 0;
          expire_date = "2028-02-09";
        };
      };
    };
  };
}
