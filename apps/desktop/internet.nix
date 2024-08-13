{ configs, pkgs, lib, ... }:
{
  users.users.richard.packages = with pkgs; [
    # browsers
    chromium

    vesktop
    telegram-desktop
    rustdesk-flutter
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "com.cassidyjames.butler"
    "one.jwr.interstellar"
    "com.bitwarden.desktop"
  ];
}
