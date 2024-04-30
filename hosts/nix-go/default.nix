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
      theme = "dpoggi";
      plugins = [ "systemd" "z" ];
    };
  };

  # config for importing builds from nixarf
  nix.settings.trusted-public-keys = [
    "nixarf:w5V0h5xBBqipR5xoY0oFE8udibTjIoh/K5GKaQbDWlc="
  ];
  nix.settings.trusted-substituters = [
    "ssh-ng://nixarf"
    "ssh://nixarf"
  ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hw-tweaks.nix
    ] ++ lib.lists.forEach [
        "/apps"
        "/system"
        "/system/printing.nix"
        "/desktop-env/gnome.nix"
        "/services/syncthing.nix"
        "/services/tailscale.nix"
      ] (p: root-config-dir + p);

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-6e545722-9bab-4c89-9e03-30652b5513c6".device = "/dev/disk/by-uuid/6e545722-9bab-4c89-9e03-30652b5513c6";
  networking.hostName = "nix-go"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
