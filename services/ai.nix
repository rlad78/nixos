{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.arf.ollama;
in
{
  options.arf.ollama = with lib; {
    models = mkOption {
      type = with types; listOf str;
      default = [ ];
    };

    context-window = mkOption {
      type = types.ints.u32; # increase limit if we ever buy crazy vram
      default = 4096;
    };
  };

  config = {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
      port = 11434;
      openFirewall = true;
      loadModels = cfg.models;
      syncModels = true;
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = toString cfg.context-window;
      };
    };

    environment.systemPackages = with pkgs; [
      llmfit
      opencode
      codex
      codex-acp
    ];
  };
}
