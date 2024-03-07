{ config, pkgs, lib, snootflix, ... }:
{
    imports = [
        ./downloaders.nix
        ./indexers.nix
        ./tools.nix
        ./plex.nix
    ];

    users.groups."${snootflix.group}" = { gid=6969; };

    systemd.tmpfiles.rules = (
        (snootflix.rootDirs ++ snootflix.mediaDirs)
        ++ [ "Z /configs 0750 - -" ]
    );
}
