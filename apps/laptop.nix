{ configs, pkgs, ... }:
{
  imports = [
    ./global.nix
    ./social.nix
    ./games.nix
    ./create.nix
    ./utils.nix
    ./productivity.nix
  ];
}
