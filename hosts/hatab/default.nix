{ config, lib, ... }:
let
    root-config-dir = ./../..;
in
{
    arf = {
        cli = {
            theme = "bira";
            plugins = [ "systemd" "z" ];
        };
        web-kiosk-url = "http://10.69.2.1:8123";
        restart = {
            enable = true;
            time = "02:00:00";
        };
        builders = [ "nixarf" ];
    };

    imports = [
        ./hardware-configuration.nix
    ] ++ lib.lists.forEach [
        "/desktop-env/kiosk.nix"
        "/system"
        "/apps/cli"
        "/hosts/common/wireless.nix"
        "/services/sshd.nix"
        "/services/restart.nix"
        "/services/tailscale.nix"
        "/services/syncthing.nix"
        "/services/nix-builder.nix"
    ] (p: root-config-dir + p);

    networking.hostName = "hatab";
    networking.networkmanager.enable = true;

    boot.loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot = {
            enable = true;
            configurationLimit = 60;
            memtest86.enable = true;
        };
    };

    system.stateVersion = "24.11";
}
