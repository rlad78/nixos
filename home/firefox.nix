{ ... }:
{
  programs.firefox = {
    enable = true;
    policies = {
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisablePocket = true;
      # DisplayBookmarksToolbar = "newtab";
      OfferToSaveLogins = false;
      ShowHomeButton = false;
    };
    profiles.default = {
      settings = {
        "sidebar.verticalTabs" = true;
        "sidebar.main.tools" = "history,bookmarks";
      };
    };
  };
}
