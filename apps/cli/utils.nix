{ pkgs, pkgs-unstable, ... }:
{
  environment.systemPackages = with pkgs-unstable; [
    btop
    duf
    dust
    minicom
    unzip
    udftools
  ];

  users.users.richard.extraGroups = [ "dialout" ];
}
