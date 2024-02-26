{ configs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    duf
    du-dust
  ];
}
