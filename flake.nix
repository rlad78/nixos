{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.1.0";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    # pomatez-flake.url = "github:rlad78/pomatez-flake";

    nixarr = {
      url = "github:rlad78/nixarr/prod";
      # url = "path:/home/richard/nixarr/";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, nix-flatpak, nix-vscode-extensions, nixarr, ... }@inputs:
  let
#     secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");
#     hosts = builtins.fromJSON (builtins.readFile "${self}/secrets/hosts.json");
#     builders = builtins.fromJSON (builtins.readFile "${self}/system/builders.json");

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
      inherit nix-vscode-extensions;
      inherit nixarr;
    };

#     pkgsBuild = base: import base {
#       system = "x86_64-linux";
#       config.allowUnfree = true;
#     };
#
#     pkgsBuildSnootflix = base: import base {
#       system = "x86_64-linux";
#       config.allowUnfree = true;
#       config.permittedInsecurePackages = [
#         "aspnetcore-runtime-6.0.36"
#         "aspnetcore-runtime-wrapped-6.0.36"
#         "dotnet-sdk-6.0.428"
#         "dotnet-sdk-wrapped-6.0.428"
#       ];
#     };

#     host-conf-options = {
#       nix-go = {
#         pkg-base = nixpkgs-unstable;
#         build-sys = pkgsBuild;
#         special-inherits = {
#           inherit nix-flatpak;
#           inherit nix-vscode-extensions;
#         };
#         module-paths = [
#           ./hosts/nix-go
#           nixos-hardware.nixosModules.microsoft-surface-pro-intel
#           nix-flatpak.nixosModules.nix-flatpak
#         ];
#       };
#
#       nixarf = {
#         pkg-base = nixpkgs;
#         build-sys = pkgsBuild;
#         special-inherits = {};
#         module-paths = [ ./hosts/nixarf ];
#       };
#
#       snootflix = {
#         pkg-base = nixpkgs-unstable;
#         build-sys = pkgsBuildSnootflix;
#         special-inherits = {};
#         module-paths = [
#           ./hosts/snootflix
#           nixarr.nixosModules.default
#         ];
#       };

#       snootflix-mini = {
#         pkg-base = nixpkgs;
#         build-sys = pkgsBuildSnootflix;
#         special-inherits = {};
#         module-paths = [
#           ./hosts/snootflix_mini
#           nixarr.nixosModules.default
#         ];
#       };

#       nixps = {
#         pkg-base = nixpkgs-unstable;
#         build-sys = pkgsBuild;
#         special-inherits = {
#           inherit nix-flatpak;
#           inherit nix-vscode-extensions;
#         };
#         module-paths = [
#           ./hosts/nixps
#           nixos-hardware.nixosModules.dell-xps-15-9570-intel
#           nix-flatpak.nixosModules.nix-flatpak
#         ];
#       };
#     };

#     standardArgs = {
#       inherit inputs;
#       inherit secrets;
#       inherit hosts;
#       inherit builders;
#       util = import ./util.nix nixpkgs.lib;
#     };

#     systemMake = host: host.pkg-base.lib.nixosSystem {
#       specialArgs = rec {
#         pkgs = host.build-sys host.pkg-base;
#         pkgs-unstable =
#           if host.pkg-base == nixpkgs-unstable
#           then pkgs
#           else host.build-sys nixpkgs-unstable;
#         } // (host.special-inherits) // (standardArgs host.pkg-base);
#
#       modules = host.module-paths;
#     };

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
    in
    pkg-base.lib.nixosSystem {
      specialArgs = rec {
        pkgs = pkgsBuild pkg-base;
        pkgs-unstable =
          if pkg-base == nixpkgs-unstable
          then pkgs
          else pkgsBuild nixpkgs-unstable;
      } // distributeInputs;

      modules = module-paths;
    };
  in
  {
    nixosConfigurations = {

      nixarf = systemMake {
        pkg-base = nixpkgs;
        module-paths = [ ./hosts/nixarf ];
      };

      nix-go = systemMake {
        module-paths = [
          ./hosts/nix-go
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          nix-flatpak.nixosModules.nix-flatpak
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

#       snootflix-mini = systemMake host-conf-options.snootflix-mini;

      nixps = systemMake {
        module-paths = [
          ./hosts/nixps
          nixos-hardware.nixosModules.dell-xps-15-9570-intel
          nix-flatpak.nixosModules.nix-flatpak
        ];
      };

    };
  };
}
