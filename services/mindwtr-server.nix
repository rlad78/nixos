{
  config,
  lib,
  secrets,
  ...
}:
let
  cfg = config.arf.mindwtr;
in
{
  options.arf.mindwtr = with lib; {
    port = mkOption {
      type = types.port;
      default = 8787;
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/mindwtr-server";
    };

    url = mkOption {
      type = types.str;
      default = "localhost";
    };
    public = mkOption {
      type = types.bool;
      default = false;
    };

    uid = mkOption {
      type = types.ints.u32;
      default = 18787;
    };
    gid = mkOption {
      type = types.ints.u32;
      default = 18787;
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.public -> (cfg.url != "localhost");
        message = "mindwtr-server cannot be set to public and use localhost as origin url";
      }
    ];

    users = {
      users.mindwtr = {
        isSystemUser = true;
        uid = cfg.uid;
        group = "mindwtr";
      };
      groups.mindwtr = {
        gid = cfg.gid;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0770 mindwtr mindwtr"
    ];

    virtualisation.oci-containers.containers = {
      "mindwtr-server" = {
        image = "ghcr.io/dongdongbh/mindwtr-cloud:latest";
        ports = [ "${toString cfg.port}:8787" ];
        volumes = [ "${cfg.dataDir}:/app/data" ];
        user = "${toString cfg.uid}:${toString cfg.gid}";
        environment = {
          MINDWTR_CLOUD_AUTH_TOKENS = lib.concatStringsSep "," secrets.mindwtr.tokens;
          MINDWTR_CLOUD_CORS_ORIGIN = "https://${cfg.url}";
          MINDWTR_CLOUD_DATA_DIR = "/app/data";
          MINDWTR_CLOUD_TRUST_PROXY_HEADERS = "true";
          MINDWTR_CLOUD_TRUSTED_PROXY_IPS = "127.0.0.1";
        };
      };
    };

    security.acme = lib.mkIf cfg.public {
      acceptTerms = true;
      defaults.email = "goobysc@gmail.com";
    };
    services.nginx = lib.mkIf cfg.public {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      virtualHosts."${cfg.url}" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
        };
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf (!cfg.public) [ cfg.port ];
  };
}
