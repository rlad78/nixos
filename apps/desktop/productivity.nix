{ pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    onlyoffice-desktopeditors
    obsidian
  ];
}
