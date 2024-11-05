{ config, pkgs, lib, ... }:
let
  padfix_script = ./padfix.sh;
in
{
  boot.kernelParams = [
    "i915.enable_psr=0"
  ];

  boot.extraModprobeConfig = lib.mkDefault ''
    options snd_hda_intel power_save=1
    options snd_ac97_codec power_save=1
    options iwlwifi power_save=Y
    options iwldvm force_cam=N
  '';

  systemd.services.padfix = {
    enable = true;
    description = "Reset hid-multitouch on resume from suspend";
    unitConfig = {
      After = "suspend.target";
    };
    serviceConfig = {
      ExecStart = "${padfix_script}";
    };
    wantedBy = [ "suspend.target" ];
  };

  # add a shell alias for the script just in case
  environment.shellAliases = {
    padfix = "sudo ${padfix_script}";
  };
}
