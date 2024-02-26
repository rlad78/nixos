{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    gh
    lazygit
    aria2
  ];
}
