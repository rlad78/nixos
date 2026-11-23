# in builders.json, to get publicHostKey, take the public host key
# (found using 'ssh-keyscan -t ed25519 <host>') and grab ONLY
# the key value starting with "ssh-" (ignore the hostname),
# THEN run 'echo "<KEY_VALUE>" | base64 -w0' to get the string
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

  builder-base-values = {
    sshUser = "nixbuilder";
    sshKey = "/root/.ssh/id_ed25519";
    protocol = "ssh-ng";
  };

  getWantedBuilders =
    wanted: builtins.attrValues (attrsets.filterAttrs (n: v: builtins.elem n wanted) builders);
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
      buildMachines = map (b: b // builder-base-values) (getWantedBuilders cfg.builders);
      settings = {
        builders-use-substitutes = true;
        max-jobs = cfg.localMaxJobs;
        cores = cfg.localCores;
      };
    };
  };
}
