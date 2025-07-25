{ pkgs, lib, ... }:
{
  config = {
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
      poetry
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
