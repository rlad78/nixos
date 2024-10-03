{ configs, pkgs, ... }:
{
  # users.users.richard.packages = with pkgs; [
    # vlc
  # ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "flathub org.videolan.VLC"
    "com.spotify.Client"
    "com.github.PintaProject.Pinta"
  ];
}
