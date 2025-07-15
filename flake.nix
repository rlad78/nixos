{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.1.0";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
    psonewserv = {
      url = "github:rlad78/newserv/arf-v2025-06-25";
      flake = false;
    };

    nixarr = {
      url = "github:rlad78/nixarr/prod";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, nix-flatpak, nixarr, home-manager, nixvim, firefox-gnome-theme, psonewserv,... }@inputs:
  let
    pkgsBaseArgs = add-config: {
      system = "x86_64-linux";
      config = { allowUnfree = true; } // add-config;
    };

    distributeInputs = {
      util = import ./util.nix nixpkgs.lib;
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");
      hosts = builtins.fromJSON (builtins.readFile "${self}/secrets/hosts.json");
      builders = builtins.fromJSON (builtins.readFile "${self}/system/builders.json");

      inherit nix-flatpak;
      inherit nixarr;
      inherit psonewserv;
    };

    homeBase = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit firefox-gnome-theme; };
      home-manager.users.richard = import ./home/default.nix;
    };

    systemMake = {
      pkg-base ? nixpkgs-unstable,
      pkg-args ? {},
      pkg-config-args ? {},
      module-paths ? [],
    }:
    let
      pkgsBuild = pkg: import pkg (
        (pkgsBaseArgs pkg-config-args)
        // pkg-args
      );
      default-modules = [
        nixvim.nixosModules.nixvim
      ];
    in
    pkg-base.lib.nixosSystem {
      specialArgs = { # rec {
        # pkgs = pkgsBuild pkg-base;
        # pkgs-unstable =
          # if pkg-base == nixpkgs-unstable
          # then pkgs
          # else pkgsBuild nixpkgs-unstable;
      } // distributeInputs;

      modules = module-paths ++ default-modules;
    };
  in
  {
    nixosConfigurations = {

      nixarf = systemMake {
        pkg-base = nixpkgs;
        module-paths = [ ./hosts/nixarf ];
      };

      hatab = systemMake {
        module-paths = [
          ./hosts/hatab
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
        ];
      };

      snootflix = systemMake {
        pkg-config-args = {
          permittedInsecurePackages = [
            "aspnetcore-runtime-6.0.36"
            "aspnetcore-runtime-wrapped-6.0.36"
            "dotnet-sdk-6.0.428"
            "dotnet-sdk-wrapped-6.0.428"
          ];
        };
        module-paths = [
          ./hosts/snootflix
          nixarr.nixosModules.default
        ];
      };

      nst-optiplex = systemMake {
        module-paths = [
          ./hosts/nst-optiplex
        ];
      };

      nixps = systemMake {
        module-paths = [
          ./hosts/nixps
          nixos-hardware.nixosModules.dell-xps-15-9560-intel
          nix-flatpak.nixosModules.nix-flatpak
          home-manager.nixosModules.home-manager homeBase
        ];
      };

      nixitude = systemMake {
        module-paths = [
          ./hosts/nixitude
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nix-flatpak.nixosModules.nix-flatpak
          home-manager.nixosModules.home-manager homeBase
        ];
      };

      nixitude-e = systemMake {
        module-paths = [
          ./hosts/nixitude-e
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nix-flatpak.nixosModules.nix-flatpak
          home-manager.nixosModules.home-manager homeBase
        ];
      };

      nst-van-checkout = systemMake {
        pkg-base = nixpkgs;
        module-paths = [
          ./hosts/nst-van-checkout
          nixos-hardware.nixosModules.common-cpu-intel
          nixos-hardware.nixosModules.common-pc-laptop-ssd
        ];
      };

    };
  };
}
