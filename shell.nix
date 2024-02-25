{ config, pkgs, me, machine, ... }:
let
  rebuild-alias = (method: "sudo nixos-rebuild " + method + " --flake " + me.nix_dir);
  build-func =
    ''
      nxbuild() {
        screen -dmL -Logfile ${me.build-dir}/logs/''${1}_$(date -Iminutes) -S ''${1}-build zsh -c \
            "cd ${me.nix_dir} && nix build --out-link ${me.build-dir}/''${1}_$(date -Iminutes) \
            .#nixosConfigurations.''${1}.config.system.build.toplevel"
      }
    '';
  pull-alias =
    ''
      nix copy --from ssh-ng://${me.build-server} $(ssh ${me.build-server} -- \
      "find ${me.build-dir}/ -maxdepth 1 -type l -name '*${machine.host}*' -printf '%T@&%p\n' \
      | sort -nr | head -n 1 | cut -d '&' -f 2 | xargs readlink")
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
        zoxide
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
        nxsync = "cd ${me.nix_dir} && gh repo sync";
        nxclean = "sudo nix-env --delete-generations 7d && sudo nix store gc --verbose";
        nxpull = pull-alias;
        nxs = rebuild-alias "switch";
        nxb = rebuild-alias "boot";
        lzgit = "lazygit";
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
      "d ${me.build-dir} 755 richard users"
      "d ${me.build-dir}/logs 755 richard users"
    ];

    fonts.packages = with pkgs; [
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
}

