{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    space-cadet-pinball
  ];

  services.flatpak.packages = [
    "org.libretro.RetroArch"
  ];
}
