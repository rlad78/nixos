{ ... }:
{
  imports = [
    ./base.nix
  ];

  users.users.richard.packages = with pkgs; [
    gnome-disk-utility
  ];

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
}
