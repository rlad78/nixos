{ pkgs, ... }:
{
  programs.firefox = {
    enable = false;
    policies = {
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisablePocket = true;
      # DisplayBookmarksToolbar = "newtab";
      OfferToSaveLogins = false;
      ShowHomeButton = false;
    };
    preferences = {
      "sidebar.verticalTabs" = true;
      "sidebar.main.tools" = "history,bookmarks";
    };
  };

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "com.bitwarden.desktop"
    "org.chromium.Chromium"
    "app.zen_browser.zen"
    "dev.vencord.Vesktop"
    "org.telegram.desktop"
    "org.gabmus.whatip"
    "xyz.ketok.Speedtest"
  ];
}
