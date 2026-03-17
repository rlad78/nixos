{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
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
