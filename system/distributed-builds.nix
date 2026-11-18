{
  config,
  lib,
  builders,
  ...
}:
with lib;
let
  cfg = config.arf.remoteBuilds;

  builder-names = builtins.attrNames builders;
  builder-extra-attrs = [
    "public-key"
  ];

  getWantedBuilders =
    wanted: builtins.attrValues (attrsets.filterAttrs (n: v: builtins.elem n wanted) builders);

  getWantedBuilderAttrs = attr: wanted: attrsets.catAttrs attr (getWantedBuilders wanted);
in
{
  options.arf.remoteBuilds = {
    builders = mkOption {
      type = types.listOf (types.enum builder-names);
      default = [ ];
    };

    localCores = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = null;
      example = 2;
      description = ''
        Number of cores requested per local build, or null to leave the host's
        existing setting unchanged. Zero means all available cores.
      '';
    };

    localMaxJobs = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = null;
      example = 1;
      description = ''
        Maximum concurrent local builds, or null to leave the host's existing
        setting unchanged. Zero disables local builds and therefore local fallback.
      '';
    };
  };

  config = mkIf ((lists.length cfg.builders) > 0) {
    nix = {
      distributedBuilds = true;
      buildMachines = map (b: removeAttrs b builder-extra-attrs) (getWantedBuilders cfg.builders);
      settings = {
        builders-use-substitutes = true;
        max-jobs = cfg.localMaxJobs;
        cores = cfg.localCores;
      };
    };
  };
}
