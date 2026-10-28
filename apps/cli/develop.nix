{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    codex
    poetry
    nixpkgs-fmt
    nil
    nixd
    distrobox
  ];
}
