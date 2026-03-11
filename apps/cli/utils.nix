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
    codex-acp
    nil
    nixd
  ];

  users.users.richard.extraGroups = [ "dialout" ];
}
