{ config, lib, pkgs, ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      # keep this for remote nix build
      PermitRootLogin = "yes";
      AllowUsers = [ "root" ];
    };
  };
}