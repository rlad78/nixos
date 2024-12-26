{ configs, pkgs, pkgs-unstable, ... }:
let
  myRetroArch = (pkgs-unstable.retroarch.withCores
    (cores: with cores; [
      mgba
      fceumm
      snes9x2005-plus
      genesis-plus-gx
      beetle-saturn
    ])
  );
in
{
  environment.systemPackages = with pkgs; [
    myRetroArch
  ];

  programs.gamemode.enable = true;

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "com.github.k4zmu2a.spacecadetpinball"
    "org.gnome.Mahjongg"
  ];
}

