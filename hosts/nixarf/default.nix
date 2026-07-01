{
  lib,
  pkgs,
  hosts,
  ...
}:
let
  root-config-dir = ./../..;
in
{
  arf = {
    gc = {
      enable = true;
      frequency = "weekly";
      older-than = 31;
    };
    cli = {
      theme = "candy";
      plugins = [
        "systemd"
        "z"
      ];
    };
    # rustdesk.publicIP = "69.59.79.150";
    inner-nat = true;
    ollama = {
      host = hosts.nixarf.tail-ip;
      waitForTailscale = true;
      models = [ "qwen3.5:9b" ];
      context-window = 16 * 1024;
      keep-alive = "20m";
    };
    searxng = {
      bind-address = hosts.nixarf.tail-ip;
      waitForTailscale = true;
      port = 5454;
    };
  };

  imports = [
    ./hardware-configuration.nix
    ./storage-disk.nix
  ]
  ++ lib.lists.forEach [
    "/desktop-env/no-desktop.nix"
    "/hosts/common/nvidia.nix"
    "/system"
    "/apps/cli"
    "/apps/cli/distrobox.nix"
    "/services/sshd.nix"
    "/services/tailscale.nix"
    "/services/syncthing.nix"
    "/services/scrutiny.nix"
    "/services/pdf.nix"
    "/services/nix-builder.nix"
    "/services/hass.nix"
    # "/services/rustdesk.nix"
    "/services/pinchflat.nix"
    # "/services/fah.nix"
    # "/services/hytale.nix"
    "/services/ollama.nix"
    "/services/searxng.nix"
  ] (p: root-config-dir + p);

  # needed for Jellyfin YouTube metadata plugin
  environment.systemPackages = with pkgs; [
    yt-dlp
    ffmpeg
  ];

  boot.kernelParams = [
    "fsck.mode=force"
    "fsck.repair=yes"
  ];

  # leave two cores open on builds
  nix.settings.max-jobs = 6;

  systemd.services.jellyfin.path = [ pkgs.yt-dlp ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "storage";
  };

  systemd.tmpfiles.rules = [
    "d /storage/yt 0770 jellyfin users"
  ];

  users.users.jellyfin.extraGroups = [ "users" ];

  # networking
  networking.hostName = "nixarf";

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      configurationLimit = 60;
      memtest86.enable = true;
    };
  };

  users.users.richard.extraGroups = [
    "networkmanager"
    "wheel"
  ];

  system.stateVersion = "23.11"; # Did you read the comment?

}
