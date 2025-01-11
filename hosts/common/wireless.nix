{ lib, ... }:
let
  secrets-dir = ./../../secrets;
in
{
  networking.wireless = {
    enable = true;
    networks = {
      snootnet.pskRaw = "ext:psk_snoot";
    };
    secretsFile = "${secrets-dir}/keys.txt";
  };

  networking.networkmanager.enable = lib.mkForce false;
}
