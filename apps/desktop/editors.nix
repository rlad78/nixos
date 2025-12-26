{ config, pkgs, pkgs-unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    pkgs-unstable.poetry
    nixd
    nixpkgs-fmt
  ];
}
