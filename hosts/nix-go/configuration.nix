# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   persistent = true;
  #   options = "--delete-older-than 14d";
  # };
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

  # # allow flakes
  # nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # # Allow unfree packages
  # nixpkgs.config.allowUnfree = true;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hw-tweaks.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-6e545722-9bab-4c89-9e03-30652b5513c6".device = "/dev/disk/by-uuid/6e545722-9bab-4c89-9e03-30652b5513c6";
  networking.hostName = "nix-go"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # # Set your time zone.
  # time.timeZone = "America/New_York";

  # # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";

  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "en_US.UTF-8";
  #   LC_IDENTIFICATION = "en_US.UTF-8";
  #   LC_MEASUREMENT = "en_US.UTF-8";
  #   LC_MONETARY = "en_US.UTF-8";
  #   LC_NAME = "en_US.UTF-8";
  #   LC_NUMERIC = "en_US.UTF-8";
  #   LC_PAPER = "en_US.UTF-8";
  #   LC_TELEPHONE = "en_US.UTF-8";
  #   LC_TIME = "en_US.UTF-8";
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
