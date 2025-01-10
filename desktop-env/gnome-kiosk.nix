# no, not thaaaat gnome-kiosk, just gnome that acts like a good kiosk

{ config, pkgs, lib, ... }:
let
    cfg = config.arf.kiosk;
    cfg-startup-arguments = lib.strings.concatStringsSep " " cfg.startupArguments;
in
{
    options.arf.kiosk = with lib; {
        enable = mkEnableOption "";
        startupPackage = mkOption {
            type = types.package;
            default = pkgs.firefox;
        };
        startupPathSuffix = mkOption {
            type = types.str;
            default = "/bin/firefox";
        };
        startupArguments = mkOption {
            type = types.listOf str;
            default = [
                "-kiosk"
                "https://google.com/"
            ];
        };
    };

    config = {
        imports = [ ./base.nix ];

        users.users.kiosk = {
            isNormalUser = true;
            packages = [ cfg.startupPackage ];
        };

        services.xserver.displayManager.gdm = {
            enable = lib.mkDefault true;
            wayland = lib.mkDefault true;
        };

        services.displayManager.autoLogin = {
            enable = true;
            user = "kiosk";
        };

        # workaround for gdm autologin issues
        # https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
        systemd.services."getty@tty1".enable = false;
        systemd.services."autovt@tty1".enable = false;

        services.xserver.desktopManager.gnome.enable = lib.mkDefault true;

        environment.gnome.excludePackages = (with pkgs; [
            atomix # puzzle game
            cheese # webcam tool
            epiphany # web browser
            evince # document viewer
            geary # email reader
            gedit # text editor
            gnome-characters
            gnome-music
            gnome-photos
#             gnome-terminal
            gnome-tour
            hitori # sudoku game
            iagno # go game
            tali # poker game
            totem # video player
        ]);

        systemd.user.services.kiosk-program = lib.mkIf cfg.enable {
            wantedBy = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];
            after = [ "graphical-session.target" "network-online.target" ];
            wants = [ "network-online.target" ];
            serviceConfig = {
                ExecStart = "${cfg.startupPackage}${cfg.startupPathSuffix} ${cfg-startup-arguments}";
            };
        };
    };
}
