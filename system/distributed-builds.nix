{ config, lib, builders, ... }:
with lib; let
  cfg = config.arf;

  this-host = config.networking.hostName;
  build-subs = config.nix.settings.trusted-substituters;
  build-server = if build-subs != []
    then lists.last (strings.splitString "//" (builtins.head (build-subs)))
    else "";
  build-dir = toString (config.users.users.richard.home + "/builds");
    
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

  pull-alias =
  ''
    nix copy --from ssh-ng://${build-server} $(ssh ${build-server} -- \
    "find ${build-dir}/ -maxdepth 1 -type l -name '*${this-host}*' -printf '%T@&%p\n' \
    | sort -nr | head -n 1 | cut -d '&' -f 2 | xargs readlink")
  '';

  shell-aliases = {
    nxpull = pull-alias;
  };
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
      b: removeAttrs b builder-extra-attrs) (
      getWantedBuilders cfg.builders
    );

    environment.shellAliases = shell-aliases;
  };
}
