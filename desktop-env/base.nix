{ pkgs, lib, ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = lib.mkDefault true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # enable powerprofilesctl
  services.power-profiles-daemon.enable = true;

  fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
  ];
}
