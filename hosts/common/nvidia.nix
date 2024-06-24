{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    cudatoolkit
  ];

  services.xserver.videoDrivers = lib.mkDefault [ "nvidia" ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

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
}
