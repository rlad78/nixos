{ config, pkgs, ... }:

{
  networking.hostName = "nixarf"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
    };
  };

  services.tailscale.enable = true;
  services.tailscale.port = 41641;
  environment.systemPackages = with pkgs; [ tailscale ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall.allowedUDPPorts = [ 41641 ];
}