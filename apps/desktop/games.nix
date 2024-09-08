{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    space-cadet-pinball
    gnome-mahjongg
  ];

  environment.systemPackages = with pkgs; [
    (retroarch.override {
      cores = with libretro; [
        mgba
        fceumm
        snes9x2005-plus
        genesis-plus-gx
        beetle-saturn
      ];
    })
  ];

  programs.gamemode.enable = true;
}

