# Import this module on a machine that will accept remote Nix builds.
#
# Example host configuration:
#   imports = [ ../../system/nix-builder-new.nix ];
#   arf.nixBuilder = {
#     authorizedKeys = [ "ssh-ed25519 AAAA... nixpad-builder" ];
#     # Set this if the host already restricts SSH with AllowUsers.
#     addToAllowUsers = true;
#   };
#
# The client must separately configure nix.buildMachines, an SSH private key
# readable by its Nix daemon, and host-key verification. This module does not
# create private keys, configure a binary cache, or select client builders.
{ config, lib, ... }:
let
  cfg = config.arf.nixBuilder;
in
{
  options.arf.nixBuilder = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "nixbuilder";
      description = "Dedicated system user and group for the remote builder.";
    };

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "ssh-ed25519 AAAA... nixpad-builder" ];
      description = "Public SSH keys allowed to connect as the builder user. Never put private keys here.";
    };

    authorizedKeyFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Files containing public SSH authorized keys for the builder user.";
    };
  };

  config = {
    imports = [ ./sshd.nix ];

    services.openssh = {
      settings.AllowUsers = [ cfg.user ];
    };

    users.groups.${cfg.user} = { };
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.user;
      useDefaultShell = true;
      openssh.authorizedKeys = {
        keys = cfg.authorizedKeys;
        keyFiles = cfg.authorizedKeyFiles;
      };
    };

    # Nix trusted users have root-equivalent authority on this machine.
    nix.settings.trusted-users = [ cfg.user ];

    warnings = lib.optional (cfg.authorizedKeys == [ ] && cfg.authorizedKeyFiles == [ ])
      "arf.nixBuilder: no SSH public keys configured; remote builder login will not work until a key is authorized.";
  };
}
