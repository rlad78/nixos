{ config, pkgs, lib, ... }:
let
  cfg = config.arf.nixvim;
  plug-on = { enable = true; autoLoad = true; };
in
{
  options.arf.nixvim = with lib; {
    colorscheme = mkOption {
      type = types.enum [
        "ayu"
        "bamboo"
        "base16"
        "catppuccin"
        "cyberdream"
        "dracula"
        "dracula-nvim"
        "everforest"
        "github-theme"
        "gruvbox"
        "kanagawa"
        "kanagawa-paper"
        "melange"
        "modus"
        "monokai-pro"
        "nightfox"
        "nord"
        "one"
        "onedark"
        "oxocarbon"
        "palette"
        "poimandres"
        "rose-pine"
        "tokyonight"
        "vscode"
      ];
      default = "cyberdream";
    };
  };

  config = {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      extraConfigVim = ''
        set tabstop=2
        set shiftwidth=2
        set expandtab
        set smartindent
        set rnu
        let g:transparent_enabled = v:true
      '';

      colorschemes.${cfg.colorscheme}.enable = true;

      plugins = {
        nix = plug-on;
        lightline = plug-on;
        visual-multi = plug-on;
        transparent = plug-on;

        barbar = {
          enable = true;
          autoLoad = true;
          keymaps = with lib; {
            close.key = "<A-x>";
            closeAllButCurrent.key = "<A-S-x>";
            first.key = "<A-S-h>";
            last.key = "<A-S-l>"; 
            next.key = "<A-l>";
            previous.key = "<A-h>";
            moveNext.key = "<A-S-k>";
            movePrevious.key = "<A-S-j>";
            goTo1.key = "<A-1>";
            goTo2.key = "<A-2>";
            goTo3.key = "<A-3>";
            goTo4.key = "<A-4>";
            goTo5.key = "<A-5>";
            goTo6.key = "<A-6>";
            goTo7.key = "<A-7>";
            goTo8.key = "<A-8>";
            goTo9.key = "<A-9>";
          }; 
        };
        web-devicons.enable = true; # required for barbar

        neo-tree = {
          enable = true;
          closeIfLastWindow = true;
          settings = {
            event_handlers = {
              file_opened = ''
                function(file_path)
                  --auto close
                  require("neo-tree").close_all()
                end
              '';
            };
          };
        };
      };
    };
  };
}
