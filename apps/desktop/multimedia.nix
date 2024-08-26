{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    spotify
    pinta
    vlc
  ];
}
