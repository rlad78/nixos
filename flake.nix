{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
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
        };
        
        modules = [ 
          ./hosts/nixarf/configuration.nix
          ./shell.nix
          ./tailscale.nix
          ./software/fah.nix
          ./software/syncthing.nix
          ./software/torrent.nix
          ./software/netdata.nix
          ./nvidia.nix
        ];
      };
    };
  };
}
