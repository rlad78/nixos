{ ... }:
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.AllowUsers = [ "richard" ];
  };

  environment.enableAllTerminfo = true;
}