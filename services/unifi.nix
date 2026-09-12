{ ... }:
{
  virtualisation.podman.enable = true;

  services.unifi-os-server = {
    enable = true;
    uosSystemIP = "10.69.2.1";
    openFirewallUiPort = true;
    openFirewallServicePorts = true;
  };
}
