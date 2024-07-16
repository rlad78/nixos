{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.1.0";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    pomatez-flake.url = "github:rlad78/pomatez-flake";

    nixarr = {
      url = "github:rlad78/nixarr/sabnzbd";
      # url = "path:/home/richard/nixarr/";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, nix-flatpak, nix-vscode-extensions, nixarr, pomatez-flake, ... }@inputs:
  let
    secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");
    hosts = builtins.fromJSON (builtins.readFile "${self}/secrets/hosts.json");

    standardArgs = nixpkgs-input: {
      inherit inputs;
      inherit secrets;
      inherit hosts;
      util = import ./util.nix nixpkgs-input.lib;
    };
  in
  {
    nixosConfigurations = {
      
      nixarf = nixpkgs.lib.nixosSystem {  
        specialArgs = rec {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        } // (standardArgs nixpkgs);
        
        modules = [ 
          ./hosts/nixarf
        ];
      };

      "nix-go" = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = rec {
          pkgs = import nixpkgs-unstable {
	          system = "x86_64-linux";
	          config.allowUnfree = true;
	        };
          inherit nix-flatpak;
          inherit nix-vscode-extensions;
          pomatez = pomatez-flake.packages.${pkgs.system}.default;
	      } // (standardArgs nixpkgs-unstable);

    	  modules = [
	        ./hosts/nix-go
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          nix-flatpak.nixosModules.nix-flatpak
	      ];
      };

      snootflix = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = rec {
          pkgs = import nixpkgs-unstable {
            system = "x86_64-linux";
	          config.allowUnfree = true;
          };
        } // (standardArgs nixpkgs-unstable);

        modules = [
          ./hosts/snootflix
          nixarr.nixosModules.default
        ];
      };
    };
  };
}
