{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    retroarch-with-cores
    retroarch-assets-unstable
    space-cadet-pinball
    typespeed
  ];

  # services.flatpak.packages = [
    # "org.libretro.RetroArch"
  # ];

  programs.gamemode.enable = true;
}

