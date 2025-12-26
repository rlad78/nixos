{ pkgs, pkgs-unstable, lib, ... }:
{
  config = {
    # enable flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    
    # pkgs required for flakes and shell
    environment.systemPackages = with pkgs; [
      git
      curl
      git-crypt
      screen
      poetry
      pkgs-unstable.gh
      pkgs-unstable.lazygit
    ];
    
    environment.shellAliases = {
      lzgit = "lazygit";
    };
    
    programs.zsh = {
      enable = true;
      autosuggestions = {
        enable = true;
        strategy = [
          "completion"
          "history"
        ];
      };
    };
  };
}
