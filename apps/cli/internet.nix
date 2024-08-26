{ configs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gh
    lazygit
    aria2
    # termshark
    speedtest-cli
  ];

  users.users.richard.extraGroups = [ "wireshark" ];

  # security.wrappers.termshark = {
    # owner = "root";
    # group = "root";
    # source = "${pkgs.termshark}/bin/termshark";
    # capabilities = "cap_net_raw,cap_net_admin+eip";
  # };
}
