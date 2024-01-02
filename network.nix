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
  environment.systemPackages = with pkgs; [ tailscale ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall.allowedUDPPorts = [ ${services.tailscale.port} ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}