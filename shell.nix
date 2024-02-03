{ config, pkgs, me, machine, ... }:
let
  build-func =
    ''
      nxbuild() {
        screen -dmL -Logfile /home/richard/builds/logs/''${1}_$(date -Iminutes) -S ''${1}-build zsh -c \
            "cd ${me.nix_dir} && gh repo sync && nix build --out-link /home/richard/builds/''${1}_$(date -Iminutes) \
            .#nixosConfigurations.''${1}.config.system.build.toplevel"
      }
    '';
in
{
    # user packages
    environment.systemPackages = with pkgs; [
        git
        curl
        screen
        zsh
        lsd
        tldr
        btop
        broot
        duf
        du-dust
        gh
        lazygit
	      aria2
        ripgrep
    ];

    programs.neovim = {
        enable = true;
        defaultEditor = true;
        vimAlias = true;
        configure = {
            customRC = ''
                set tabstop=2
                set shiftwidth=2
                set expandtab
                set smartindent
            '';
        };
    };

    users.users.richard.shell = pkgs.zsh;
    services.openssh.settings.AllowUsers = [ "richard" ];

    #shell settings
    environment.shellAliases = {
        sudo = "sudo ";
        ls = "lsd";
        ll = "lsd -l";
        la = "lsd -la";
        nxsync = "cd /home/richard/nixos/ && gh repo sync";
        nxclean = "sudo nix-store --gc";
        nxs = "sudo nixos-rebuild switch --flake " + me.nix_dir;
        nxb = "sudo nixos-rebuild boot --flake " + me.nix_dir;
        lzgit = "lazygit";
        fup = "cd " + me.nix_dir + " && sudo nix flake update && sudo nixos-rebuild switch --flake " + me.nix_dir; 
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

        promptInit = build-func;

        ohMyZsh = {
            enable = true;
            plugins = machine.omz.plugins;
            theme = machine.omz.theme; 
            customPkgs = with pkgs; [
                nix-zsh-completions
            ];
        };
    };

    systemd.tmpfiles.rules = [
      "d /home/richard/builds 755 richard users"
      "d /home/richard/builds/logs 755 richard users"
    ];

    fonts.packages = with pkgs; [
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
}

