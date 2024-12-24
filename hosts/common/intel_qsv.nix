{ config, pkgs, ... }:
{
  boot.kernelParams = [
    "i915.enable_guc=2"
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-media-sdk
      intel-compute-runtime
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  environment.systemPackages = with pkgs; [
    intel-gpu-tools
  ];

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };
}
