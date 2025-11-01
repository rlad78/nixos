{ configs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    duf
    dust
    minicom
    unzip
    udftools
  ];

  users.users.richard.extraGroups = [ "dialout" ];
}
