{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.1.0";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    pomatez-flake.url = "path:/home/richard/devel/pomatez-flake";

    nixarr = {
      url = "github:rlad78/nixarr/sabnzbd";
      # url = "path:/home/richard/nixarr";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, nix-flatpak, nix-vscode-extensions, nixarr, pomatez-flake, ... }@inputs:
  let
    secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");

    hosts = {

      nixarf = {
        tail-ip = "100.122.79.3";
        local-ip = "10.0.1.5";
        sync-id = "ABISHSV-HVJT5IF-QG3SN7U-UIRE6U3-FIB5EAA-AWQMTYJ-ANXYOEV-XYTOJQV";
        sync-port = "22000";
      };

      nix-go = {
        tail-ip = "100.96.155.115";
        local-ip = "10.0.1.41";
        sync-id = "JOQ6PH5-IZ7O33M-4TCTJK6-NE5SRKB-NFYDZRX-AIJASWD-2Y7FMT7-7NY54QX";
        sync-port = "22000";
      };

      samsung-s23 = {
        tail-ip = "100.68.133.55";
        local-ip = "10.0.1.35";
        sync-id = "FVMMLEQ-E2J6XRX-G2OIBLH-7AVNNQI-4B2TUKN-VNIQB6U-5JTHPYI-MY4EOQP";
        sync-port = "22000";
      };

      NextArf = {
        tail-ip = "100.83.96.68";
        local-ip = "10.0.1.2";
        sync-id = "IJMXDUY-MVTMAI7-5GDSLJS-6Q74X2P-IRT2YOU-A7KNJ5W-7GFY6QY-XKX5BAB";
        sync-port = "22000";
      };

      snootflix = {
        tail-ip = "100.78.22.40";
        local-ip = "10.0.1.6";
        sync-id = "IUNJ33Y-CE5LJYO-2WN5RMA-M4KDDFS-55Z3MED-MXSA5EO-Z2PQSWO-7OKHHQP";
        sync-port = "22000";
      };

      snootflix-site = {
        tail-ip = "100.65.85.130";
      };

      snoothome = {
        local-ip = "10.0.2.111";
        tail-ip = "100.85.137.97";
      };

      hatab = {
        local-ip = "10.0.1.71";
      };
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
          inherit inputs;
          inherit secrets;
          inherit hosts;
        };
        
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
          inherit inputs;
          inherit secrets;
	        inherit hosts;
          inherit nix-flatpak;
          inherit nix-vscode-extensions;
          pomatez = pomatez-flake.packages.${pkgs.system}.default;
	      };

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
	  inherit inputs;
	  inherit secrets;
	  inherit hosts;
        };

        modules = [
          ./hosts/snootflix
          nixarr.nixosModules.default
        ];
      };
    };
  };
}
