{ config, pkgs, lib, ... }:
{
  boot.kernelParams = [
    "i915.enable_psr=0"
    "i915.enable_rc6=1"
  ];

  boot.extraModprobeConfig = lib.mkDefault ''
    options snd_hda_intel power_save=1
    options snd_ac97_codec power_save=1
    options iwlwifi power_save=Y
    options iwldvm force_cam=N
  '';

  # disable ipts, causes systemd errors and
  #  touchscreen works fine without it
  microsoft-surface.ipts.enable = lib.mkForce false;
}
