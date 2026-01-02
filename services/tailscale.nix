{ config, pkgs-unstable, inputs, ... }:
{
  services.tailscale = {
    enable = true;
    package = pkgs-unstable.tailscale;
    openFirewall = true;
  };
}
