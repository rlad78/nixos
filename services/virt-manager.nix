{ pkgs, ... }:
{
  programs.virt-manager = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    dnsmasq
  ];

  users.groups.libvirtd.members = [ "richard" ];

  virtualisation.libvirtd.enable = true;
}
