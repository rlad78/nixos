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
    "one.jwr.interstellar"
    "com.bitwarden.desktop"
    "org.chromium.Chromium"
    "dev.vencord.Vesktop"
    "org.telegram.desktop"
  ];
}
