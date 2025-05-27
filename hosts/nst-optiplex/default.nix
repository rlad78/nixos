{ config, lib, ... }:
let
  root-config-dir = ./../..;
in
{
  arf = {
    no-nat = true;
    gc = {
      enable = true;
      frequency = "weekly";
      older-than = 14;
    };
    cli = {
      theme = "clean";
      plugins = [ "systemd" "z" ];
    };
  };

  imports = [
    ./hardware-configuration.nix
  ] ++ lib.lists.forEach [
    "/desktop-env/no-desktop.nix"
    "/system"
    "/apps/cli"
    "/services/tailscale.nix"
    "/services/ytdl.nix"
  ];
  
  networking.hostname = "nst-optiplex";
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      configuration-limit = 40;
      memtest86.enable = true;
    };
  };

  users.users.richard.extraGroups = [ "networkmanager" "wheel" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
