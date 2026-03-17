{ pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    peazip
  ];

  services.flatpak.packages = [
    "com.github.tchx84.Flatseal"
    "org.filezillaproject.Filezilla"
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;
}
