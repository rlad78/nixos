{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.1.0";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, nix-flatpak, nix-vscode-extensions, ... }@inputs:
  let
    me = rec {
      nix_dir = "~/nixos/";
      build-server = "nixarf";
      build-dir = "/home/richard/builds";
      hosts = {

        nixarf = {
          tail-ip = "100.126.98.98";
          local-ip = "10.0.1.5";
          sync-id = "4HSWZPG-DE4VAWM-32OQEZS-OPKP6T2-NRA6XQL-LV2DJDY-4PAEQR3-LNLCDQ7";
          sync-port = "22000";
        };

        nix-go = {
          tail-ip = "100.96.155.115";
          local-ip = "10.0.3.10";
          sync-id = "JOQ6PH5-IZ7O33M-4TCTJK6-NE5SRKB-NFYDZRX-AIJASWD-2Y7FMT7-7NY54QX";
          sync-port = "22000";
        };

        samsung-s23 = {
          tail-ip = "100.68.133.55";
          local-ip = "10.0.3.13";
          sync-id = "FVMMLEQ-E2J6XRX-G2OIBLH-7AVNNQI-4B2TUKN-VNIQB6U-5JTHPYI-MY4EOQP";
          sync-port = "22000";
        };

        the-doghouse = {
          tail-ip = "100.68.24.62";
          local-ip = "10.0.1.2";
          sync-id = "35RITKL-BGKLWI3-RC3L3M5-R3OSQ4B-RZIVOTP-CS7H7UW-7ZKD2FX-ZLSB7QQ";
          sync-port = "22000";
        };

        snootflix4 = {
          tail-ip = "100.83.200.46";
        };

        snootflix-site = {
          tail-ip = "100.65.85.130";
        };

        snoothome = {
          local-ip = "10.0.2.111";
          tail-ip = "100.85.137.97";
        };

        hatab = {
          local-ip = "10.0.3.11";
        };
      };
      local-addresses = with nixpkgs.lib.attrsets; (this-host:
        mapAttrsToList (n: v: v.local-ip) (
          filterAttrs (n: v: hasAttrByPath ["local-ip"] v) (
            removeAttrs hosts [this-host]
          )
        )
      );
      tail-addresses = with nixpkgs.lib.attrsets; (this-host:
        mapAttrsToList (n: v: v.tail-ip) (
          filterAttrs (n: v: hasAttrByPath ["tail-ip"] v) (
            removeAttrs hosts [this-host]
          )
        )
      );
      all-host-addresses = (this-host:
        (local-addresses this-host) ++ (tail-addresses this-host)
      );
    };
    snootflix = with nixpkgs.lib; rec {
      group = "snootflix";
      categories = [
        "movies"
        "tv"
        "anime"
      ];
      dirs = {
        main = "/snootflix";
        config = "/snootflix/configs";
        download = "/snootflix/downloads";
      };

      mkDirFunc = root: path: "d " + root + "/" + path + " 0770 richard " + group;
      mkDirsFunc = root: paths: builtins.map (mkDirFunc root) paths;
      mkRootDirs = attrsets.mapAttrsToList (n: v:
        "d " + v + " 0770 richard " + group
      ) dirs;

      mkMainDir = path: mkDirFunc dirs.main path;
      mkConfDir = path: mkDirFunc dirs.config path;
      mkConfPath = parts: strings.concatStringsSep "/" (
        (lists.singleton dirs.config) ++ parts
      );

      mkMediaDirs = builtins.map mkMainDir (
        builtins.map strings.toUpper categories
      );
      mkDownloadDirs = (downloaders: lists.flatten (
        lists.forEach downloaders
          (dl: mkDirsFunc (dirs.download + "/" + dl) categories)
        )
      );
    };
  in
  {
    nixosConfigurations = {
      
      nixarf = nixpkgs.lib.nixosSystem {  
        specialArgs = {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          inherit me;
          inherit snootflix;
          machine = {
            system = "x86_64-linux";
            host = "nixarf";
            eth-interface = "enp0s25";
            omz = {
              theme = "candy";
              plugins = [ "systemd" "z" ];
            };
          };
        };
        
        modules = [ 
          ./hosts/common
          ./hosts/nixarf/configuration.nix
          ./richard.nix
          ./shell.nix
          ./apps/cli
          ./services/tailscale.nix
          ./services/fah.nix
          ./services/syncthing.nix
          ./services/torrent.nix
          ./services/netdata.nix
        ];
      };

      "nix-go" = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = {
          pkgs = import nixpkgs-unstable {
	          system = "x86_64-linux";
	          config.allowUnfree = true;
	        };
	        inherit me;
          inherit nix-flatpak;
          inherit nix-vscode-extensions;
          machine = {
            system = "x86_64-linux";
            host = "nix-go";
            eth-interface = "wlp0s20f3";
            omz = {
              theme = "dpoggi";
              plugins = [ "systemd" "z" ];
            };
          };
	      };

    	  modules = [
          ./hosts/common
	        ./hosts/nix-go/configuration.nix
          ./gnome
          ./apps
          ./richard.nix
	        ./shell.nix
	        ./services/tailscale.nix
          ./services/syncthing.nix
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          nix-flatpak.nixosModules.nix-flatpak
          # home-manager.nixosModules.home-manager {
            # home-manager.useGlobalPkgs = true;
            # home-manager.useUserPackages = true;
            # home-manager.users.richard = ./home.nix
          # }
	      ];
      };
    };
  };
}
