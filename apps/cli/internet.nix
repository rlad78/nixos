{ configs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    aria2
    # termshark
    speedtest-cli
    dig
    trippy
  ];

  environment.shellAliases = {
    public-ip = "dig +short myip.opendns.com @resolver1.opendns.com";
  };

  # users.users.richard.extraGroups = [ "wireshark" ];

  # security.wrappers.termshark = {
    # owner = "root";
    # group = "root";
    # source = "${pkgs.termshark}/bin/termshark";
    # capabilities = "cap_net_raw,cap_net_admin+eip";
  # };
}
