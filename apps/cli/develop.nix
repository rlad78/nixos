{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    codex
    codex-acp
    poetry
    nixpkgs-fmt
    nil
    nixd
  ];
}
