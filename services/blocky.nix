{ config, pkgs, lib, ... }:
{
  services.blocky = {
    enable = true;
    settings = {
      upstreams = {
        strategy = "strict";
        groups.default = [
          "https://one.one.one.one/dns-query" 
          "8.8.8.8"
          "8.8.4.4"
        ];
      };

      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [ "1.1.1.1" "1.0.0.1" ];
      };

      blocking = {
        blackLists.ads = [
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        ];
        clientGroupsBlock.default = [ "ads" ];
      };

      # caching = {
        # minTime = "5m";
        # maxTime = "30m";
        # prefetching = true;
      # };
    };
  };
}
