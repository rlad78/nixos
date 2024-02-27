{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    foot
  ];

  services.flatpak.packages = [
    "com.github.tchx84.Flatseal"
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;
}
