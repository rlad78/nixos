{ configs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gh
    lazygit
    aria2
  ];
}
