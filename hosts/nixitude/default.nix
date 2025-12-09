{ lib, ... }:
let
  root-config-dir = ./../..;
in
{
  arf = {
    cli.theme = "fishy";
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

  boot.initrd.luks.devices."luks-6d6e8c4f-e79f-472b-b999-01c756d1d7ff".device = "/dev/disk/by-uuid/6d6e8c4f-e79f-472b-b999-01c756d1d7ff";

  networking.hostName = "nixitude"; # Define your hostname.
  system.stateVersion = "24.11"; # Did you read the comment?
}
