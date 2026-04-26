{ config, lib, pkgs, ... }:
{
  config = lib.mkMerge [
    {
      # enable flakes
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # pkgs required for flakes and shell
      environment.systemPackages = with pkgs; [
        git
        curl
        git-crypt
        screen
        poetry
        gh
        lazygit
      ];

      environment.shellAliases = {
        lzgit = "lazygit";
      };

      programs.zsh = {
        enable = true;
        autosuggestions = {
          enable = true;
          strategy = [
            "completion"
            "history"
          ];
        };
      };
    }

    (lib.mkIf config.virtualisation.docker.enable {
      systemd.services.docker-image-prune = {
        description = "Prune unused Docker images";
        after = [ "docker.service" ];
        wants = [ "docker.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.docker}/bin/docker image prune -a -f";
        };
      };

      systemd.timers.docker-image-prune = {
        wantedBy = [ "timers.target" ];
        description = "Monthly Docker image prune";
        timerConfig = {
          OnCalendar = "*-*-01 03:00:00";
          Persistent = true;
          Unit = "docker-image-prune.service";
        };
      };
    })
  ];
}
