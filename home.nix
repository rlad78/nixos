{ configs, pkgs, ... }:
{
  home.username = "richard";
  home.homeDirectory = "/home/richard";

  home.packages = with pkgs; [
    # for later
  ];

  programs = {
    foot = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMonoNerdFontMono:size=10";
          pad = "4x8";
        };
      };
    };

  };
}
