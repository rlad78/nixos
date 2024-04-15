{ config, lib, ... }:
with lib; let
  cfg = config.arf.gc;
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

    # enable flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # allow unfree
    nixpkgs.config.allowUnfree = true;
  };
}