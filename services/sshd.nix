{ pkgs, ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.AllowUsers = [ "richard" ];
  };

  # environment.enableAllTerminfo = true;
  environment.systemPackages = with pkgs; [
    alacritty.terminfo
  ];
}
