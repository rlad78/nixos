{ config, pkgs, lib, ... }:
let
  cfg = config.arf.cli;

  mkdown-func =
    ''
      mkdown() {
        sudo install -d -m ''${4:-0755} -o ''$2 -g ''${3:-$2} ''$1
      }
    '';

  shell-functions = [ mkdown-func ];
in
{
  options.arf.cli = with lib; {
    theme = mkOption {
      type = types.str;
      default = "robbyrussell"; 
    };
    plugins = with types; mkOption {
      type = listOf str;
      default = [ "systemd" ];
    };
  };
    
  config = {
    environment.systemPackages = with pkgs; [
      eza
      tldr
      ripgrep
      zoxide
      fzf
      nnn
    ];

    programs.fzf = {
      keybindings = true;
      fuzzyCompletion = true;
    };

    #shell settings
    environment.shellAliases = {
      sudo = "sudo ";
      ls = "eza --icons=always";
      ll = "eza --icons=always -lgh";
      la = "eza --icons=always -lagh";
      lt = "eza --icons=auto -T";
      mountctl = "systemd-mount";
    };

    programs.zsh = {
      enable = true;

      autosuggestions = {
        enable = true;
        strategy = [
          "completion"
          "history"
        ];
      };

      promptInit = lib.strings.concatStrings shell-functions;

      ohMyZsh = {
        enable = true;
        plugins = cfg.plugins;
        theme = cfg.theme; 
        customPkgs = with pkgs; [
          nix-zsh-completions
        ];
      };
    };
  };
}

