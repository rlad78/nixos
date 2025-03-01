{ config, ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    loadModels = [ "deepseek-r1:32b" ];
  };

  services.nextjs-ollama-llm-ui = {
    enable = true;
    hostname = "0.0.0.0";
    port = 3000;
  };

  networking.firewall.allowedTCPPorts = [ config.services.nextjs-ollama-llm-ui.port ];
}
