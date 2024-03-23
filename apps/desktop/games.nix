{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    # space-cadet-pinball
    gnome.gnome-mahjongg
    moonlight-qt
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "org.libretro.RetroArch"
  ];

  programs.gamemode.enable = true;
}

