{ config, pkgs, ... }:
{
  imports = [
    ./networking.nix
    ./dirs.nix
  ];
}
