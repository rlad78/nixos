{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    bitwarden
  ];

  services.flatpak.packages = [
    "com.github.tchx84.Flatseal"
    "com.cassidyjames.butler"
  ];
}
