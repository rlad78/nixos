{ configs, pkgs, lib, ... }:
{
  users.users.richard.packages = with pkgs; [
    # browsers
    floorp
    ungoogled-chromium

    bitwarden
    vesktop
    telegram-desktop
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "dev.geopjr.Tuba"
    "com.cassidyjames.butler"
    "one.jwr.interstellar"
  ];
}
