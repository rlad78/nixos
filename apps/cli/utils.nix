{ configs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    duf
    du-dust
    minicom
    unzip
    udftools
  ];

  users.users.richard.extraGroups = [ "dialout" ];
}
