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
  services.displayManager.gdm.enable = lib.mkDefault true;
  services.desktopManager.gnome.enable = lib.mkDefault true;

  users.users.richard.packages = with pkgs; [
    # dynamic-wallpaper
    gnome-tweaks
    vanilla-dmz
  ] ++ gnome-extensions;

  environment.gnome.excludePackages = with pkgs; [
    atomix
    epiphany
    geary
    gnome-tour
    iagno
    tali
    totem
    gnome-music
    gnome-maps
    gnome-software
    simple-scan
    yelp
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "com.mattjakeman.ExtensionManager"
    "me.dusansimic.DynamicWallpaper"
  ];
}
