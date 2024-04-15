{ configs, pkgs, lib, ... }:
{
  imports = [
    ../apps/desktop/gnome.nix
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = lib.mkDefault true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = lib.mkDefault true;
  services.xserver.desktopManager.gnome.enable = lib.mkDefault true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # enable powerprofilesctl
  services.power-profiles-daemon.enable = true;

  # make sure we have some kind of fallback browser
  users.users.richard.packages = [ pkgs.firefox ];
}

