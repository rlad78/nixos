{ configs, pkgs, pkgs-unstable, ... }:
{
  environment.systemPackages = with pkgs-unstable; [
    mpv
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "com.spotify.Client"
    "org.gimp.GIMP"
    "io.gitlab.adhami3310.Converter"
    "be.alexandervanhee.gradia"
  ];
}
