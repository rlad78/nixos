{ config, pkgs, inputs, ... }:
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
}
