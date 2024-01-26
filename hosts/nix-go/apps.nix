{ configs, pkgs, me, uncommon, ... }:
{
  users.users.richard = {
    packages = with pkgs; [
      floorp
      space-cadet-pinball
      blackbox-terminal
      vesktop
      telegram-desktop
    ];
  }; 

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "org.libretro.RetroArch"
    "com.mattjakeman.ExtensionManager"
    "md.obsidian.Obsidian"
    "com.github.tchx84.Flatseal"
    "com.cassidyjames.butler"
    "io.github.giantpinkrobots.varia"
  ];
}
