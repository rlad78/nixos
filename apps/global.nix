{ configs, pkgs, lib, ... }:
let
  browsers = with pkgs; [
    floorp
    firefox
  ];
in
{
  users.users.richard.packages = [
    # put global packages here
  ] ++ browsers;

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;
}
