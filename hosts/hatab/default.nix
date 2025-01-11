{ lib, ... }:
let
    root-config-dir = ./../..;
in
{
    arf = {
        cli = {
            theme = "bira";
            plugins = [ "systemd" "z" ];
        };
#         kiosk = {
#             enable = false;
#             startupArguments = [
#                 "-kiosk"
#                 "http://10.69.2.1:8123"
#             ];
#         };
        web-kiosk-url = "http://10.69.2.1:8123";
    };

    imports = [
        ./hardware-configuration.nix
    ] ++ lib.lists.forEach [
#         "/desktop-env/gnome-kiosk.nix"
        "/desktop-env/kiosk.nix"
        "/system"
        "/apps/cli"
        "/hosts/common/wireless.nix"
        "/services/tailscale.nix"
        "/services/syncthing.nix"
        "/services/sshd.nix"
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
