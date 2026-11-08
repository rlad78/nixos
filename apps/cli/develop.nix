{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    poetry
    nixpkgs-fmt
    nil
    nixd
  ];
}
