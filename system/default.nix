{ config, ... }:
{
  imports = [
    ./base.nix
    ./cli.nix
    ./hosts.nix
    ./locale.nix
    ./nix.nix
    ./richard.nix
    ./ssh.nix
    ./networking.nix
    ./distributed-builds.nix
  ];
}
