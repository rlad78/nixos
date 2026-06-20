{
  config,
  lib,
  ...
}:
let
  cfg = config.arf.hermes;
in
{
  options.arf.hermes = with lib; {
    llm-host = mkOption {
      type = types.str;
    };

    main-model = mkOption {
      type = types.str;
    };
  };

  config = {
    services.hermes-agent = lib.mkIf cfg.hermes.enable {
      enable = true;
      addToSystemPackages = true;
      settings = {
        model = {
          default = cfg.main-model;
          provider = "custom";
          base_url = cfg.llm-host;
        };
        terminal.backend = "local";
        compression.enabled = true;
        memory = {
          memory_enabled = true;
          user_profile_enabled = true;
        };
        display = {
          compact = false;
          personality = "kawaii";
        };
      };
    };
  };
}
