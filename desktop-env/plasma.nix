{ config, pkgs, lib, ... }:
{
  imports = [
    ./base.nix
  ];

  # Enable KDE Plasma 6
  services.desktopManager.plasma6.enable = lib.mkDefault true;
  services.displayManager.sddm.enable = lib.mkDefault true;

  # Enable experimental Wayland support for sddm
  services.displayManager.sddm.wayland.enable = true;

  # Enable KDE Connect
  programs.kdeconnect.enable = true;

  # Fonts for Plasma
  fonts.packages = with pkgs; [
    ibm-plex
  ];

  # enable flatpaks
  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "eu.betterbird.Betterbird"
  ];

  users.users.richard.packages = with pkgs; [
    # spell checking
    aspell
    aspellDicts.en
    aspellDicts.en-computers

    # disk quota widget
    kdePackages.plasma-disks

    # help out flatpaks
    xdg-desktop-portal-gnome
  ];
}
