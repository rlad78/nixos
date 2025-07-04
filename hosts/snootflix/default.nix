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
        "/services/sshd.nix"
        "/services/scrutiny.nix"
      ] (p: root-config-dir + p);

  # networking
  networking.hostName = "snootflix"; # Define your hostname.

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

