{ configs, pkgs, ... }:
{
  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "md.obsidian.Obsidian"
  ];
}
