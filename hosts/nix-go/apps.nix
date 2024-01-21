{ configs, pkgs, me, uncommon, ... }:
{
  users.users.richard = {
    packages = with pkgs; [
      retroarchFull
      floorp
      space-cadet-pinball
      blackbox-terminal
      vesktop
      telegram-desktop
    ];
  }; 
}
