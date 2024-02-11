{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    space-cadet-pinball
    typespeed
  ];

  services.flatpak.packages = [
    "org.libretro.RetroArch"
  ];

  programs.gamemode.enable = true;
}

