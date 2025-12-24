{ configs, pkgs, ... }:
let
  myRetroArch = (pkgs.retroarch.withCores
    (cores: with cores; [
      mgba
      fceumm
      snes9x2005-plus
      genesis-plus-gx
      beetle-saturn
      beetle-psx-hw
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
    "dev.bragefuglseth.Keypunch"
    "com.valvesoftware.Steam"
    "org.vinegarhq.Sober"
  ];
}

