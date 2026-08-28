{
  config,
  lib,
  secrets,
  ...
}:
let
  cfg = config.arf.searxng;
in
{
  options.arf.searxng = with lib; {
    port = mkOption {
      type = types.port;
      default = 5454;
    };

    waitForTailscale = mkEnableOption "";

    bind-address = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };

    openFirewall = mkEnableOption "";
  };

  config = {
    services.searx = {
      enable = true;
      redisCreateLocally = true;
      settings = {
        server = {
          bind_address = cfg.bind-address;
          port = cfg.port;
          secret_key = secrets.searxng-secret-key;
        };

        # Hermes consumes SearXNG's JSON Search API. SearXNG returns 403
        # unless each non-HTML response format is explicitly enabled.
        search.formats = [
          "html"
          "json"
        ];
      };
    };

    systemd.services.searx = lib.mkIf cfg.waitForTailscale {
      requires = [ "tailscaled.service" ];
      after = [ "tailscaled.service" ];
    };

    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.openFirewall || cfg.waitForTailscale) [ cfg.port ];
  };
}
