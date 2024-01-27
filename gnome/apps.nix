{ configs, pkgs, ... }:
{
  users.users.richard = {
    packages = with pkgs; [
      dynamic-wallpaper
      blackbox-terminal
   ];
  };

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "com.mattjakeman.ExtensionManager"
  ];
}
