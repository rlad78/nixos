{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-hardware-surface.url = "github:8bitbuddhist/nixos-hardware?ref=surface-rust-target-spec-fix";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.1.0";
    nixarr.url = "github:rasmus-kirk/nixarr";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-hardware,
    nixos-hardware-surface,
    nix-flatpak,
    nixarr,
    nixvim,
    ...
  }@inputs:
  let
    pkgsBaseArgs = {
      system = "x86_64-linux";
      config = { allowUnfree = true; };
    };

    modulesForAllSystems = [
      nixvim.nixosModules.nixvim
    ];

    distributeInputs = {
      util = import ./util.nix nixpkgs.lib;
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets/secrets.json");
      hosts = builtins.fromJSON (builtins.readFile "${self}/secrets/hosts.json");
      builders = builtins.fromJSON (builtins.readFile "${self}/system/builders.json");

      inherit nix-flatpak;
      inherit nixarr;
    };

    systemMake = { module-paths ? [] }: nixpkgs.lib.nixosSystem {
      specialArgs = rec {
        pkgs-unstable = import nixpkgs-unstable pkgsBaseArgs;
      } // distributeInputs;

      modules = module-paths ++ modulesForAllSystems;
    };
  in
  {
    nixosConfigurations = {

      nixarf = systemMake {
        module-paths = [ ./hosts/nixarf ];
      };

      nst-van-checkout-surface = systemMake {
        module-paths = [
          ./hosts/nst-van-checkout-surface
          nixos-hardware-surface.nixosModules.microsoft-surface-pro-intel
        ];
      };

      snootflix = systemMake {
        module-paths = [
          ./hosts/snootflix2
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
    };
  };
}
