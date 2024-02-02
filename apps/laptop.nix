{ configs, pkgs, ... }:
{
  imports = [
    ./social.nix
    ./games.nix
    ./create.nix
    ./utils.nix
  ];
}
