{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    pinta
  ];

  services.flatpak.packages = [
    "dev.geopjr.Tuba"
    "md.obsidian.Obsidian"
  ];
}
