{ config, pkgs, lib, ... }:
let
  cfg = config.arf.nvidia;
in
{
  options.arf.nvidia = with lib; {
    version = mkOption {
      type = types.enum [ "stable" "beta" "production" ];
      default = "stable";
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
      cudatoolkit
    ];

    services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.${cfg.version};

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    hardware.nvidia = {
      # Modesetting is required.
      modesetting.enable = true;

      # independent third-party "nouveau" open source driver).
      open = false;

      # nvidia-persistenced a update for NVIDIA GPU headless mode 
      # i.e. It ensures all GPUs stay awake even during headless mode
      nvidiaPersistenced = true;
    };
  };
}
