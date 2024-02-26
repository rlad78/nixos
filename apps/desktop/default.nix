{ configs, pkgs, ... }:
{
  imports = [
    ./editors.nix
    ./games.nix
    ./gnome.nix
    ./internet.nix
    ./multimedia.nix
    ./productivity.nix
    ./utils.nix
  ];
}
