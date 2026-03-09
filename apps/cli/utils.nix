{ pkgs, pkgs-unstable, ... }:
{
  environment.systemPackages = with pkgs-unstable; [
    btop
    duf
    dust
    minicom
    unzip
    udftools
    zellij
    codex
  ];

  users.users.richard.extraGroups = [ "dialout" ];
}
