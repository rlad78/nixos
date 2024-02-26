{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    # (spacevim.override {
      # spacevim_config = import ../configs/spacevim.nix;
    # })
    lunarvim
  ];

  environment.shellAliases = {
    # sv = "spacevim";
    lv = "lunarvim"
  };
}
