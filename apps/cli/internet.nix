{ configs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
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
