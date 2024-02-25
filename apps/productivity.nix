{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    (spacevim.override {
      spacevim_config = import ./configs/spacevim.nix;
    })
  ];

  environment.shellAliases = {
    sv = "spacevim";
  };
}
