{ configs, pkgs, lib, ... }:
let
  gnome-extensions = with pkgs.gnomeExtensions; [
    auto-power-profile
    caffeine
    runcat
    night-theme-switcher
    paperwm
    search-light
    no-overview
    grand-theft-focus
  ];
in
{
  imports = [
    ./base.nix
  ];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = lib.mkDefault true;
  services.xserver.desktopManager.gnome.enable = lib.mkDefault true;

  users.users.richard.packages = with pkgs; [
    dynamic-wallpaper
    gnome.gnome-tweaks
  ] ++ gnome-extensions;

  programs.geary.enable = true;

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "com.mattjakeman.ExtensionManager"
  ];
}
