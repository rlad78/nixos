{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    retroarchFull
    retroarch-assets
    space-cadet-pinball
    typespeed
  ];

  # services.flatpak.packages = [
    # "org.libretro.RetroArch"
  # ];

  programs.gamemode.enable = true;
}

