{ config, lib, pkgs, ... }:
let
  root-config-dir = ./../..;
in
{
  arf = {
    gc = {
      enable = true;
      frequency = "weekly";
      older-than = 21
    };
    cli = {
      theme = "gallifrey";
      plugins = [ "systemd" "z" ];
    };
  };

  imports = [
    ./hardware-configuration.nix
  ] ++ lib.lists.forEach [
    "/desktop-env/plasma.nix"
    "/system"
    "/apps/cli"
    "/services/tailscale.nix"
    "/services/sshd.nix"
  ] (p: root-config-dir + p);

  networking.hostName = "gateway-station"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}