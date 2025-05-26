# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
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
      theme = "jonathan";
      plugins = [ "systemd" "z" ];
    };
    nvidia.version = "production";
    ytdl = {
      enable = true;
      workingDir = /snoot/ytdl;
    };
    romm = {
      enable = true;
      libraryDir = /snoot/romm_library;
      consoles = [
        "gba"
        "gbc"
        "nds"
        "n64"
        "genesis-slash-megadrive"
        "nes"
        "ps"
        "snes"
      ];
    };
  };

  imports =
    [
      ./hardware-configuration.nix
      ./media.nix
      ./other_hosted.nix
    ] ++ lib.lists.forEach [
        "/desktop-env/no-desktop.nix"
        "/hosts/common/nvidia.nix"
        "/system"
        "/apps/cli/internet.nix"
        "/apps/cli/utils.nix"
        "/apps/cli/editors.nix"
        "/services/tailscale.nix"
        "/services/syncthing.nix"
        "/services/romm.nix"
        "/services/ytdl.nix"
      ] (p: root-config-dir + p);

  services.scrutiny = {
    enable = true;
    openFirewall = true;
    collector.enable = true;
    settings.web.listen.port = 9999;
  };

  # networking
  networking.hostName = "snootflix"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "yes";
      AllowUsers = [ "root" ];
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      configurationLimit = 60;
      memtest86.enable = true;
    };
  };

  users.users.richard.extraGroups = [ "networkmanager" "wheel" ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}

