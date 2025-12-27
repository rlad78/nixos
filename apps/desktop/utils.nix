{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    # kitty
    # kitty-themes
    # ghostty
  ];

  services.flatpak.packages = [
    "com.github.tchx84.Flatseal"
    "org.filezillaproject.Filezilla"
    "github.peazip.PeaZip"
  ];

  # environment.shellAliases = {
    # kssh = "kitty +kitten ssh";
  # };

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;
}
