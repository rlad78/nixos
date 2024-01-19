{ config, pkgs, lib, ... }:

let
    snootdirs = dirs: lib.lists.forEach dirs (dir:
        "d " + dir + " 0770 root snootflix"
    )
{
    imports = [
        ./downloaders.nix
        ./indexers.nix
        ./tools.nix
        ./plex.nix
    ];

    users.groups.snootflix = {};

    systemd.tmpfiles.rules = snootdirs [
        "/snootflix"
        "/snootflix/downloads"
        "/snootflix/downloads/incomplete"

        "/snootflix/ANIME"
        "/snootflix/downloads/anime"

        "/snootflix/ANIME_MOVIES"
        "/snootflix/downloads/anime_movies"

        "/snootflix/MOVIES"
        "/snootflix/downloads/movies"

        "/snootflix/TV"
        "/snootflix/downloads/tv"
    ];
}