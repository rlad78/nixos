{ pkgs, ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.AllowUsers = [ "richard" ];
  };

  environment.systemPackages = with pkgs; [
    alacritty.terminfo
  ];
}
