{ config, pkgs, ... }:

{
    # immutable users
    users.mutableUsers = false;


    # user packages
    environment.systemPackages = with pkgs; [
        zsh
        lsd
        tldr
    ];


    # root settings
    users.users.root.hashedPassword = "$6$vsOaxNJFEUCh3Z0K$2te0jZJfabO18pj58vXSr.J345ECzAZsUtCoHJL2NgZ/FE9m00Vt0asxXiX.aDWBtad./f5kelep1uVNjbeKE/";


    # richard settings
    users.users.richard = {
        isNormalUser = true;
        extraGroups = [ "wheel" ]
        packages = with pkgs; [
            gh
            xonsh
        ];
        hashedPassword = "$6$SkIi1e6zfsLHIUvR$Xg3ZYvL5EsEh/jzcvHX2s6O0a5Z7RmyWRyeLGMMsh6XJnCcTZmrM4EC4N0n08WlIiJP2radM56K6UpLXvb122/";
    };

    users.users.richard.shell = pkgs.zsh;
    services.openssh.settings.AllowUsers = [ "richard" ]


    #shell settings
    environment.shellAliases = {
        ls = "lsd";
        ll = "lsd -l";
        la = "lsd -la";
    };

    programs.zsh = {
        enable = true;

        autosuggestions = {
            enable = true;
            strategy = [
                "completion"
                "history"
            ];
        };

        ohMyZsh = {
            enable = true;
            plugins = [ "systemd" ];
            theme = "candy";
            customPkgs = with pkgs; [
                nix-zsh-completions
            ];
        };
    };

    fonts.packages = with pkgs; [
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
}