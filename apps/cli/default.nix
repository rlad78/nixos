{ configs, pkgs, ... }:
{
  imports = [
    ./develop.nix
    ./editors.nix
    ./games.nix
    ./internet.nix
    ./utils.nix
  ];
}
