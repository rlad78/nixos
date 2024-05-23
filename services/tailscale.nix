{ config, pkgs, inputs, ... }:
{
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/programs/nh.nix"
  ];

  services.tailscale = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux.tailscale;
  };

  networking.firewall.allowedUDPPorts = [ 41641 ];
}
