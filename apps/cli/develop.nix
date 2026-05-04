{ pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
  };

  programs.appimage = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    codex
    poetry
    nixpkgs-fmt
    nil
    nixd
    distrobox
  ];
}
