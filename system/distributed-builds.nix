{ config, lib, builders, ... }:
with lib; let
  cfg = config.arf;
  
  builder-names = builtins.attrNames builders;
  builder-extra-attrs = [
    "public-key"
  ];

  getWantedBuilders = wanted: builtins.attrValues (
    attrsets.filterAttrs (n: v: builtins.elem n wanted) builders
  );

  getWantedBuilderAttrs = attr: wanted: attrsets.catAttrs attr (
    getWantedBuilders wanted
  );
in
{
  options.arf.builders = mkOption {
    type = types.listOf (types.enum builder-names);
    default = [];
  };

  config = mkIf ((lists.length cfg.builders) > 0) {
    nix.settings.trusted-public-keys = getWantedBuilderAttrs "public-key" cfg.builders;

    nix.settings.trusted-substituters = lists.forEach (
      getWantedBuilderAttrs "hostName" cfg.builders) (
      host: "ssh-ng://${host}"
    );

    nix.distributedBuilds = true;
    nix.extraOptions = ''
      builders-use-substitutes = true
    '';

    nix.buildMachines = map (
      b: removeAttrs builder-extra-attrs) (
      getWantedBuilders cfg.builders
    );
  };
}
