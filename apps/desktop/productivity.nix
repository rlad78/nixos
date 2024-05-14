{ configs, pkgs, lib, pomatez, ... }:
{
  users.users.richard.packages = with pkgs; [
    libreoffice-fresh
    # pomatez
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "md.obsidian.Obsidian"
  ];

  
}
