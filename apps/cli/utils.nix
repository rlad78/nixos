{ configs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    duf
    du-dust
    minicom
  ];

  users.users.richard.extraGroups = [ "dialout" ];
}
