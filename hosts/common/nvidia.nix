{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.arf.nvidia;
in
{
  options.arf.nvidia = with lib; {
    version = mkOption {
      type = types.enum [
        "stable"
        "beta"
        "production"
      ];
      default = "stable";
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
      cudatoolkit
    ];

    services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.${cfg.version};

    hardware.graphics.enable = true;

    hardware.nvidia = {
      nvidiaSettings = true;

      # Modesetting is required.
      modesetting.enable = true;

      # independent third-party "nouveau" open source driver).
      open = false;

      # nvidia-persistenced a update for NVIDIA GPU headless mode
      # i.e. It ensures all GPUs stay awake even during headless mode
      nvidiaPersistenced = true;
    };

    # add new nixos nvidia cache
    nix.settings = {
      substituters = [ "https://cache.nixos-cuda.org" ];
      trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
    };
  };
}
