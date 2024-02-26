{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    btop
    duf
    du-dust
  ];
}
