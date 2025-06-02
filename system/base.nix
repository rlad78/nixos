{ pkgs, ... }:
{
  # enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # pkgs required for flakes and shell
  environment.systemPackages = with pkgs; [
    zsh
    git
    gh
    curl
    lazygit
    git-crypt
    screen
  ];

  environment.shellAliases = {
      lzgit = "lazygit";
  };
}