{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    poetry
    nixd
    nixpkgs-fmt
    zed-editor
  ];
}
