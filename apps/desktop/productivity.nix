{ config, pkgs, pkgs-unstable, ... }:
{
  users.users.richard.packages = with pkgs-unstable; [
    (if config.services.desktopManager.plasma6.enable == true
      then libreoffice-qt6
      else libreoffice
    )
    hunspell
    hunspellDicts.en_US
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "md.obsidian.Obsidian"
  ];
}
