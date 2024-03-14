{ config, pkgs, nixified-ai, ... }:
{
  # imports = [ nixified-ai.nixosModules.invokeai-nvidia ];

  # nix.settings.trusted-substituters = ["https://ai.cachix.org"];
  # nix.settings.trusted-public-keys = ["ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="];

  # services.invokeai.enable = true;

  environment.systemPackages = with pkgs; [
    ollama
    conda
  ]
}
