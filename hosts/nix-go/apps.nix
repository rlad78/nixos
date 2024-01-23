{ configs, pkgs, me, uncommon, ... }:
{
  users.users.richard = {
    packages = with pkgs; [
      floorp
      space-cadet-pinball
      blackbox-terminal
      vesktop
      telegram-desktop
      # sublime4
    ];
  }; 

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "org.libretro.RetroArch"
    "com.mattjakeman.ExtensionManager"
    "md.obsidian.Obsidian"
  ];
}
