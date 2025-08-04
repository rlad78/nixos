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
      older-than = 31;
    };
    cli = {
      theme = "candy";
      plugins = [ "systemd" "z" ];
    };
    rustdesk.publicIP = "69.59.79.150";
  };

  imports =
    [
      ./hardware-configuration.nix
		  ./storage-disk.nix
    ] ++ lib.lists.forEach [
        "/desktop-env/no-desktop.nix"
        "/system"
        "/apps/cli"
        "/services/sshd.nix"
        "/services/tailscale.nix"
        "/services/syncthing.nix"
        "/services/scrutiny.nix"
        "/services/pdf.nix"
        "/services/webdav.nix"
        "/services/nix-builder.nix"
        "/services/hass.nix"
        "/services/rustdesk.nix"
      ] (p: root-config-dir + p);

  # needed for Jellyfin YouTube metadata plugin
  environment.systemPackages = with pkgs; [
    yt-dlp
    ffmpeg
  ];

  systemd.services.jellyfin.path = [ pkgs.yt-dlp ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d /storage/yt 0770 jellyfin users"
  ];

  users.users.jellyfin.extraGroups = [ "users" ];

  # networking
  networking.hostName = "nixarf";

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

