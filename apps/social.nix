{ configs, pkgs, ...}:
{
  users.users.richard.packages = with pkgs; [
    vesktop  # discord client
    telegram-desktop
  ];

  services.flatpak.packages = [
    "dev.geopjr.Tuba"
  ];
}
