{ ... }:
{
  users.users.bazarr = {
    isSystemUser = true;
    group = "media";
  };

  services.bazarr = {
    enable = true;
    user = "bazarr";
    group = "media";
    openFirewall = true;
  };
}
