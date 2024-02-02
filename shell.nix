{ config, pkgs, me, machine, ... }:
let
  build-cmd =
    ''
      ssh nixarf -f "screen -dmL -Logfile /home/richard/remote_builds/logs/${HOST}_$(date -Iseconds) -t ${HOST}-build zsh -c 'cd /home/richard/nixos && gh repo sync && nix build --out-link /home/richard/remote_builds/build_${HOST}_$(date -Iseconds) .#nixosConfigurations.${HOST}.config.system.build.toplevel'"
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
        trippy
        termshark
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
        nxbld = build-cmd;
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
            plugins = machine.omz.plugins;
            theme = machine.omz.theme; 
            customPkgs = with pkgs; [
                nix-zsh-completions
            ];
        };
    };

    fonts.packages = with pkgs; [
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
}

