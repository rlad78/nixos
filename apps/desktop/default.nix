{ configs, pkgs, ... }:
{
  imports = [
    ./editors.nix
    ./games.nix
    ./internet.nix
    ./multimedia.nix
    ./productivity.nix
    ./utils.nix
  ];
}
