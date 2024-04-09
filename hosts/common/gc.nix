{ config, lib, pkgs, ... }:
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
      type = types.string;
      default = "weekly";
    };
    older-than = mkOption {
      type = types.ints.positive;
      default = 7;
    };
  };

  config = mkIf cfg.enable {
    nix.gc = {
      automatic = true;
      dates = cfg.frequency;
      persistent = true;
      options = "--delete-older-than ${cfg.older-than}d";
    };
  };
}