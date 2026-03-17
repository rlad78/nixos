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
  ];

  users.users.richard.extraGroups = [ "dialout" ];
}
