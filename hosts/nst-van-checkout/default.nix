{ lib, ... }:
let
  root-config-dir = ./../..;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ] ++ lib.lists.forEach [
      "/roles/nst-van-checkout.nix"
      "/system/systemd-boot.nix"
    ] (p: root-config-dir + p);

  networking.hostName = "nst-van-checkout";
  system.stateVersion = "25.11";
}
