{ pkgs, pkgs-unstable, ... }:
{
  users.users.richard.packages = with pkgs-unstable; [
    typespeed
  ];
}
