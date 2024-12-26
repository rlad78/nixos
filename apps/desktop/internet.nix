{ configs, pkgs, lib, ... }:
{
  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "one.jwr.interstellar"
    "com.bitwarden.desktop"
    "io.github.zen_browser.zen"
    "org.chromium.Chromium"
    "dev.vencord.Vesktop"
    "org.telegram.desktop"
  ];
}
