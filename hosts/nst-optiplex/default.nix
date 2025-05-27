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
}
