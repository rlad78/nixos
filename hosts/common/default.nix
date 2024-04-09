{ config, pkgs, ... }:
{
  imports = [
    ./hosts.nix
    ./ssh.nix
    ./dirs.nix
    ./locale.nix
    ./global.nix
    ./gc.nix
  ];
}
