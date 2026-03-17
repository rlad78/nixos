{ config, lib, pkgs, ... }:
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
      # acceleration = "cuda";
      port = 11434;
      openFirewall = true;
      package = pkgs.ollama-cuda;
      loadModels = cfg.models;
    };

    environment.systemPackages = with pkgs; [
      llmfit
      # openclaw
    ];
  };
}
