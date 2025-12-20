{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    curl
    git
    gh
    lazygit
    git-crypt
    vim
    btrfs-progs
  ];
  
  environment.shellAliases = {
    lzgit = "lazygit";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
