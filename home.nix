{ config, pkgs, ... }:
{
  home.username = "richard";
  home.homeDirectory = "/home/richard";

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      background-opacity = 0.9;
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
