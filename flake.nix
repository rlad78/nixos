{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs: {
    nixosConfigurations = {
      
      nixarf = nixpkgs.lib.nixosSystem {  
        specialArgs = {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        
        modules = [ 
          ./configuration.nix
          ./shell.nix
          ./network.nix
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
