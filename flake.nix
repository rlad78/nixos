{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    nixpkgs-sonarr.url = "github:nixos/nixpkgs/328abff1f7a707dc8da8e802f724f025521793ea";
    # nixpkgs-sonarr.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.1.0";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    # pomatez-flake.url = "github:rlad78/pomatez-flake";

    nixarr = {
      url = "github:rlad78/nixarr/prod";
      # url = "path:/home/richard/nixarr/";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-sonarr, nixos-hardware, nix-flatpak, nix-vscode-extensions, nixarr, ... }@inputs:
  let
    secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");
    hosts = builtins.fromJSON (builtins.readFile "${self}/secrets/hosts.json");
    builders = builtins.fromJSON (builtins.readFile "${self}/system/builders.json");

    pkgsBuild = base: import base {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };

    host-conf-options = {
      nix-go = {
        pkg-base = nixpkgs-unstable;
        special-inherits = {
          inherit nix-flatpak;
          inherit nix-vscode-extensions;
        };
        module-paths = [
          ./hosts/nix-go
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          nix-flatpak.nixosModules.nix-flatpak
        ];
      };

      nixarf = {
        pkg-base = nixpkgs;
        special-inherits = {};
        module-paths = [ ./hosts/nixarf ];
      };

      snootflix = {
        pkg-base = nixpkgs-unstable;
        special-inherits = {
          pkgs-sonarr = pkgsBuild nixpkgs-sonarr;
        };
        module-paths = [
          ./hosts/snootflix
          nixarr.nixosModules.default
        ];
      };

      snootflix-mini = {
        pkg-base = nixpkgs-unstable;
        special-inherits = {};
        module-paths = [
          ./hosts/snootflix_mini
          nixarr.nixosModules.default
        ];
      };
    };

    standardArgs = nixpkgs-input: {
      inherit inputs;
      inherit secrets;
      inherit hosts;
      inherit builders;
      util = import ./util.nix nixpkgs-input.lib;
    };

    systemMake = host: host.pkg-base.lib.nixosSystem {
      specialArgs = rec {
        pkgs = pkgsBuild host.pkg-base;
        pkgs-unstable = 
          if host.pkg-base == nixpkgs-unstable
          then pkgs
          else pkgsBuild nixpkgs-unstable;
        } // (host.special-inherits) // (standardArgs host.pkg-base);

      modules = host.module-paths;
    };
  in
  {
    nixosConfigurations = {
      nixarf = systemMake host-conf-options.nixarf;
      nix-go = systemMake host-conf-options.nix-go;
      snootflix = systemMake host-conf-options.snootflix;
      snootflix-mini = systemMake host-conf-options.snootflix-mini;
    };
  };
}
