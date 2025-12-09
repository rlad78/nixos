{ lib, ... }:
let
  root-config-dir = ./../..;
in
{
  arf = {
    cli.theme = "kolo";
    nixvim.colorscheme = "monokai-pro";
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ] ++ lib.lists.forEach [
        "/roles/laptop.nix"
        "/desktop-env/plasma.nix"
        "/system/systemd-boot.nix"
      ] (p: root-config-dir + p);

  networking.hostName = "nixpad"; # Define your hostname.
  system.stateVersion = "25.11"; # Did you read the comment?
}
