{ config, pkgs, pkgs-unstable, lib, ... }:
let
  nix-cmd = "nom";
  cfg = config.arf.cli;
  home-dir = config.users.users.richard.home;
  this-host = config.networking.hostName;
  nix-dir = builtins.toString (home-dir + "/nixos");
  build-dir = builtins.toString (home-dir + "/builds");
  build-subs = config.nix.settings.trusted-substituters;
  build-server = if build-subs != []
    then lib.lists.last (lib.strings.splitString "//" (builtins.head (build-subs)))
    else "";

  rebuild-alias = (method: "sudo nixos-rebuild " + method + " --flake " + nix-dir);
  check-alias = "nix flake check --no-build --show-trace";
  build-func =
    ''
      nxbuild() {
        screen -dmL -Logfile ${build-dir}/logs/''${1}_$(date -Iminutes) -S ''${1}-build zsh -c \
            "cd ${nix-dir} && ${nix-cmd} build --out-link ${build-dir}/''${1}_$(date -Iminutes) \
            --show-trace .#nixosConfigurations.''${1}.config.system.build.toplevel \
            && find ${build-dir} -mtime +7 -execdir rm -- '{}' \;" 
      }
    '';
  nxtype-func =
    ''
      nxtype() {
        realpath $(command -v ''${1})
      }
    '';
  clean-alias = "sudo nix-env --delete-generations 14d && sudo nix store gc --verbose";
  pull-alias =
    ''
      nix copy --from ssh-ng://${build-server} $(ssh ${build-server} -- \
      "find ${build-dir}/ -maxdepth 1 -type l -name '*${this-host}*' -printf '%T@&%p\n' \
      | sort -nr | head -n 1 | cut -d '&' -f 2 | xargs readlink")
    '';

  shell-functions = [ build-func nxtype-func ];
in
{
    options.arf.cli = with lib; {
        theme = mkOption {
            type = types.str;
            default = "robbyrussell"; 
        };
        plugins = with types; mkOption {
            type = listOf str;
            default = [ "systemd" ];
        };
    };
    
    config = {
        environment.systemPackages = with pkgs; [
            git
            curl
            screen
            zsh
            eza
            tldr
            ripgrep
            zoxide
            git-crypt
            udftools
            trippy
            nix-output-monitor
            fzf
            dig
        ];

        programs.nh.enable = true;
        environment.sessionVariables.FLAKE = "/home/richard/nixos";

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

        programs.fzf = {
          keybindings = true;
          fuzzyCompletion = true;
        };

        users.users.richard.shell = pkgs.zsh;
        services.openssh.settings.AllowUsers = [ "richard" ];

        #shell settings
        environment.shellAliases = {
            sudo = "sudo ";
            ls = "eza --icons=always";
            ll = "eza --icons=always -lgh";
            la = "eza --icons=always -lagh";
            lt = "eza --icons=auto -T";
            nxclean = clean-alias;
            nxpull = pull-alias;
            nxcheck = check-alias;
            nxboot = "nh os boot && sudo reboot";
            lzgit = "lazygit";
            mountctl = "systemd-mount";
            public-ip = "dig +short myip.opendns.com @resolver1.opendns.com";
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

            promptInit = lib.strings.concatStrings shell-functions;

            ohMyZsh = {
                enable = true;
                plugins = cfg.plugins;
                theme = cfg.theme; 
                customPkgs = with pkgs; [
                    nix-zsh-completions
                ];
            };
        };

        systemd.tmpfiles.rules = [
        "d ${build-dir} 755 richard users"
        "d ${build-dir}/logs 755 richard users"
        ];

        fonts.packages = with pkgs-unstable; [
            nerd-fonts.jetbrains-mono
        ];
    };
}

