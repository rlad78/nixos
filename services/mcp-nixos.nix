{ pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    mcp-nixos
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
