{ config, lib, home-manager, ... }:
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
    ] (p: root-config-dir + p);
#     ] (p: root-config-dir + p) ++ [
#         home-manager.nixosModules.home-manager
#         {
#             home-manager.useGlobalPkgs = true;
#             home-manager.useUserPackages = true;
#             home-manager.users.kiosk = import (root-config-dir + "/desktop-env/kiosk-home.nix");
#             home-manager.extraSpecialArgs = { statever = config.system.stateVersion; };
#         }
#     ];

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
