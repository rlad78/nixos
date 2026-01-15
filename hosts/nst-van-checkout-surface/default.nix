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

  services.iptsd.enable = lib.mkDefault true;

  networking.hostName = "nst-van-checkout-surface";
  system.stateVersion = "25.11";
}
