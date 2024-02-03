{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.1.0";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, nix-flatpak, nix-vscode-extensions, ... }@inputs:
  let
    me = {
      nix_dir = "~/nixos/";
      build-server = "nixarf";
      build-dir = "/home/richard/builds";
      hosts = {

        nixarf = {
          tail-ip = "100.126.98.98";
          local-ip = "10.0.0.101";
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
        };

        hatab = {
          local-ip = "10.0.3.11";
        };
 
      };
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
          machine = {
            system = "x86_64-linux";
            host = "nixarf";
            omz = {
              theme = "candy";
              plugins = [ "systemd" ];
            };
          };
        };
        
        modules = [ 
          ./hosts/nixarf/configuration.nix
          ./richard.nix
          ./shell.nix
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
            omz = {
              theme = "dpoggi";
              plugins = [ "systemd" ];
            };
          };
	      };

    	  modules = [
	        ./hosts/nix-go/configuration.nix
          ./gnome
          ./apps/laptop.nix
          ./apps/vscode.nix
          ./richard.nix
	        ./shell.nix
	        ./services/tailscale.nix
          ./services/syncthing.nix
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          nix-flatpak.nixosModules.nix-flatpak
	      ];
      };
    };
  };
}
