{ configs, pkgs, ... }:
{
  services.flatpak.packages = [
    "com.github.tchx84.Flatseal"
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;
}
