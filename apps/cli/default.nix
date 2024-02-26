{ configs, pkgs, ... }:
{
  imports = [
    ./editors.nix
    ./games.nix
    ./internet.nix
    ./utils.nix
  ];
}
