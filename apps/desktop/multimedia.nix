{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    pinta
  ];
}
