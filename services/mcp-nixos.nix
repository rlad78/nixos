{ pkgs, nixos-mcp, ... }:
{
  users.users.richard.packages = with pkgs; [
    nixos-mcp.packages.${pkgs.stdenv.hostPlatform.system}.default
    uv
    ripgrep
    fd
    jq
    file
    nix-output-monitor
  ];

  environment.localBinInPath = true;
  programs.nix-ld.enable = true;
}
