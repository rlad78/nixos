# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  root-config-dir = ./../..;
in
{
  arf = {
    gc = {
      enable = true;
      frequency = "weekly";
      older-than = 14;
    };
    cli = {
      theme = "fishy";
      plugins = [ "systemd" "z" ];
    };
    builders = [ "nixarf" "hatab" ];
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ] ++ lib.lists.forEach [
        "/apps"
        "/system"
        "/system/printing.nix"
        "/desktop-env/gnome.nix"
        "/services/syncthing.nix"
        "/services/tailscale.nix"
      ] (p: root-config-dir + p);

  # Bootloader.
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # fwupd works for Latitude 7X80
  services.fwupd.enable = true;

  # Enable networking
  networking.hostName = "nixitude-e"; # Define your hostname.
  networking.networkmanager.enable = true;

  # add xbox one controller support
  hardware.xone.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
