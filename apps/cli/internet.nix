{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    aria2
    speedtest-cli
    dig
    trippy
    curl
  ];

  environment.shellAliases = {
    public-ip = "curl https://ipinfo.io/ip";
  };
}
