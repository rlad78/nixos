{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    gimp
    spotify
    pinta
  ];
}
