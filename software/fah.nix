{ config, pkgs, ... }:

{
    services.foldingathome = {
        enable = true;
        user = "rcarte4";
        team = 60194;
    };
}