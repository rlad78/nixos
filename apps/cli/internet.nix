{ pkgs, pkgs-unstable, ... }:
{
  environment.systemPackages = with pkgs-unstable; [
    aria2
    # termshark
    speedtest-cli
    dig
    trippy
    curl
  ];

  environment.shellAliases = {
    public-ip = "curl https://ipinfo.io/ip";
  };

  # users.users.richard.extraGroups = [ "wireshark" ];

  # security.wrappers.termshark = {
    # owner = "root";
    # group = "root";
    # source = "${pkgs.termshark}/bin/termshark";
    # capabilities = "cap_net_raw,cap_net_admin+eip";
  # };
}
