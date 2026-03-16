{ config, lib, pkgs-unstable, ... }:
let
  cfg = config.arf.ollama;
in
{
  options.arf.ollama = with lib; {
    models = mkOption {
      type = with types; listOf str;
      default = [ ];
    };
  };

  config = {
    services.ollama = {
      enable = true;
      acceleration = "cuda";
      port = 11434;
      openFirewall = true;
      package = pkgs-unstable.ollama;
      loadModels = cfg.models;
    };

    environment.systemPackages = with pkgs-unstable; [
      llmfit
      openclaw
    ];
  };
}
