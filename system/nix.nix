{ config, lib, pkgs, ... }:
with lib; let
  cfg = config.arf.gc;

  nxtype-func =
    ''
      nxtype() {
        realpath $(command -v ''${1})
      }
    '';
  
  nxsh-func =
    ''
      nxsh() {
        nix shell nixpkgs#''${1}
      }
    '';
    
  check-alias = "nix flake check --no-build --show-trace";

  shell-functions = [ nxtype-func nxsh-func ];
  shell-aliases = {
    nxcheck = check-alias;
  };
in 
{
  options.arf.gc = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    frequency = mkOption {
      type = types.str;
      default = "weekly";
    };
    older-than = mkOption {
      type = types.ints.positive;
      default = 7;
    };
  };

  config = {
    nix.gc = mkIf cfg.enable {
      automatic = true;
      dates = cfg.frequency;
      persistent = true;
      options = "--delete-older-than ${builtins.toString cfg.older-than}d";
    };

    programs.nh.enable = true;
    programs.nh.flake = "/home/richard/nixos";
    environment.sessionVariables.NH_FLAKE = "/home/richard/nixos";

    environment.shellAliases = shell-aliases;
    programs.zsh.promptInit = strings.concatStrings shell-functions;

    nixpkgs.config.allowUnfree = true;
  };
}