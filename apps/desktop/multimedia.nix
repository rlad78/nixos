{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mpv
    spotify
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "org.gimp.GIMP"
    "io.gitlab.adhami3310.Converter"
    "be.alexandervanhee.gradia"
  ];
}
