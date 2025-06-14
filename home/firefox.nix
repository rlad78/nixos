{ firefox-gnome-theme, ... }:
let
  profile-name = "default";
in
{
  home.file.".mozilla/firefox/${profile-name}/chrome/firefox-gnome-theme".source = firefox-gnome-theme;

  programs.firefox = {
    enable = true;
    policies = {
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisablePocket = true;
      DisplayBookmarksToolbar = "never";
      OfferToSaveLogins = false;
      ShowHomeButton = false;
    };
    profiles.${profile-name} = {
      id = 0;
      settings = {
        "sidebar.verticalTabs" = true;
        "sidebar.main.tools" = "history,bookmarks";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true; 
        "browser.uidensity" = 0;
        "svg.context-properties.content.enabled" = true;
        "browser.theme.dark-private-windows" = false;
      };
      userChrome = ''
        @import "firefox-gnome-theme/userChrome.css";
      '';
      userContent = ''
        @import "firefox-gnome-theme/userContent.css";
      '';
    };
  };
}
