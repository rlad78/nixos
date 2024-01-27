{ configs, pkgs, ... }:
{
  users.users.richard = {
    packages = with pkgs; [
      dynamic-wallpaper
    ];
  };
}
