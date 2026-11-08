{
  description = "Nixos config flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nixarr = {
      url = "github:rasmus-kirk/nixarr";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    psonewserv = {
      url = "github:rlad78/newserv";
      flake = false;
    };
    unifi-os-server = {
      url = "github:rcambrj/unifi-os-server";
    };
    mcp-nixos.url = "github:utensils/mcp-nixos/v3.1.0";
  };

  outputs =
    {
      self,
      nixpkgs-unstable,
      nixos-hardware,
      nix-flatpak,
      nixarr,
      psonewserv,
      unifi-os-server,
      mcp-nixos,
      ...
    }:
    let
      modulesForAllSystems = [
        # { nixpkgs.overlays = [ mcp-nixos.overlays.default ]; }
      ];

      distributeInputs = {
        util = import ./util.nix nixpkgs-unstable.lib;
        secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");
        hosts = builtins.fromJSON (builtins.readFile "${self}/secrets/hosts.json");
        builders = builtins.fromJSON (builtins.readFile "${self}/system/builders.json");

        inherit nix-flatpak;
        inherit nixarr;
        inherit psonewserv;
        inherit unifi-os-server;
        nixos-mcp = mcp-nixos;
      };

      systemMake =
        {
          module-paths ? [ ],
        }:
        nixpkgs-unstable.lib.nixosSystem {
          specialArgs = distributeInputs;
          modules = module-paths ++ modulesForAllSystems;
        };
    in
    {
      nixosConfigurations = {

        nixarf = systemMake {
          module-paths = [
            ./hosts/nixarf
          ];
        };

        snootflix = systemMake {
          module-paths = [
            ./hosts/snootflix
            nixarr.nixosModules.default
          ];
        };

        nst-van-checkout = systemMake {
          module-paths = [
            ./hosts/nst-van-checkout
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.common-pc-laptop-ssd
          ];
        };

        nixpad = systemMake {
          module-paths = [
            ./hosts/nixpad
            nixos-hardware.nixosModules.lenovo-thinkpad-l13
            nix-flatpak.nixosModules.nix-flatpak
          ];
        };

        snoothome = systemMake {
          module-paths = [
            ./hosts/snoothome
            unifi-os-server.nixosModules.unifi-os-server
            nixos-hardware.nixosModules.common-cpu-intel-cpu-only
          ];
        };
      };
    };
}
