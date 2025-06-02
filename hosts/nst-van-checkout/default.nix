{ config, pkgs, lib, ... }:
let
  root-config-dir = ./../..;
in
{
  arf = {
    gc = {
      enable = true;
      frequency = "monthly";
      older-than = 14;
    };
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./van-checkout.nix
    ] ++ lib.lists.forEach [
        "/system/barebones.nix"
        "/system/networking.nix"
        "/system/auto-rebuild.nix"
        "/services/sshd.nix"
        "/desktop-env/plasma.nix"
      ] (p: root-config-dir + p);

  # Bootloader.
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.hostName = "nst-vcheckout-laptop"; # Define your hostname.
  networking.networkmanager.enable = true;

  # we need a browser
  environment.systemPackages = with pkgs; [ firefox ];

  # automatically log in to Plasma session
  services.displayManager.autoLogin = {
    enable = true;
    user = "richard";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
