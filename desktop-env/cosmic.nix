{ pkgs, pkgs-unstable, ... }:
{
  imports = [
    ./base.nix
  ];

  users.users.richard.packages = with pkgs-unstable; [
    gnome-disk-utility
  ];

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
}
