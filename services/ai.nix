{ config, pkgs-unstable, ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    port = 11434;
    openFirewall = true;
    package = pkgs-unstable.ollama;
    # loadModels = [ "deepseek-r1:32b" ];
  };

  environment.systemPackages = with pkgs-unstable; [
    llmfit
  ];

  # services.nextjs-ollama-llm-ui = {
  #   enable = true;
  #   hostname = "0.0.0.0";
  #   port = 3000;
  # };

  # networking.firewall.allowedTCPPorts = [ config.services.nextjs-ollama-llm-ui.port ];
}
