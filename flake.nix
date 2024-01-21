{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, ... }@inputs:
  let
    me = {
      nix_dir = "~/nixos/";
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
          uncommon = {
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
          ./tailscale.nix
          ./software/fah.nix
          ./software/syncthing.nix
          ./software/torrent.nix
          ./software/netdata.nix
          ./nvidia.nix
        ];
      };

      "nix-go" = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = {
          pkgs = import nixpkgs-unstable {
	          system = "x86_64-linux";
	          config.allowUnfree = true;
	        };
	        inherit me;
          uncommon = {
            omz = {
              theme = "dpoggi";
              plugins = [ "systemd" ];
            };
          };
	      };

    	  modules = [
	        ./hosts/nix-go/configuration.nix
          ./richard.nix
	        ./shell.nix
	        ./tailscale.nix
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
	      ];
      };
    };
  };
}
