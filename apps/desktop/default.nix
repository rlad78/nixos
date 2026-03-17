{ configs, pkgs, ... }:
{
  imports = [
    ./develop.nix
    ./games.nix
    ./internet.nix
    ./multimedia.nix
    ./productivity.nix
    ./utils.nix
  ];
}
