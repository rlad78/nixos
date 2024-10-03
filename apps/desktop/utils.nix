{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    kitty
    kitty-themes
    wezterm
  ];

  services.flatpak.packages = [
    "com.github.tchx84.Flatseal"
  ];

  environment.shellAliases = {
    kssh = "kitty +kitten ssh";
  };

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;
}
