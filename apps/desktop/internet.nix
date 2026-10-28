{ pkgs, ... }:
{
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  users.users.richard.packages = with pkgs; [
    chromium
    vesktop
    telegram-desktop
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "com.bitwarden.desktop"
    "app.zen_browser.zen"
    "org.gabmus.whatip"
  ];
}
