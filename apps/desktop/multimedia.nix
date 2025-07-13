{ configs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vlc
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "com.spotify.Client"
    "org.gimp.GIMP"
  ];
}
