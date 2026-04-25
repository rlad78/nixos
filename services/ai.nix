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

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };

    context-window = mkOption {
      type = types.ints.u32;
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
      host = cfg.host;
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = toString cfg.context-window;
        # OLLAMA_FLASH_ATTENTION = 0;
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
