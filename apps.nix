{ configs, pkgs, ...}:
{
  users.users.richard = {
    packages = with pkgs; [
      floorp
      space-cadet-pinball
      vesktop
      telegram-desktop
      pinta
    ];
  }; 

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "org.libretro.RetroArch"
    "md.obsidian.Obsidian"
    "com.github.tchx84.Flatseal"
    "com.cassidyjames.butler"
  ];
}
