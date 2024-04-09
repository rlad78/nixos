{ config, lib, pkgs, ... }:
{
  # enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # allow unfree
  nixpkgs.config.allowUnfree = true;
  
}