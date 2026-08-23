{
  config,
  pkgs,
  ...
}:
let
  user = "richard";
  # richard is the established primary NixOS account (UID 1000).
  uid = "1000";
  gid = toString config.users.groups.${config.users.users.${user}.group}.gid;
  docker = "${pkgs.docker}/bin/docker";
in
{
  # Keep a Docker daemon in richard's user namespace. The system-level
  # Docker daemon remains available for the other OCI services on nixarf.
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Start richard's user manager and rootless Docker daemon at boot, even
  # when nobody has logged in locally.
  users.users.${user}.linger = true;

  # The persistent named volume avoids host UID/GID mapping problems that
  # rootless containers can have with bind mounts. Hermes's entrypoint maps
  # its in-container hermes user to these IDs before it writes state.
  systemd.services.docker-hermes = {
    description = "Hermes Agent rootless container";
    after = [
      "network-online.target"
      "user@${uid}.service"
    ];
    wants = [
      "network-online.target"
      "user@${uid}.service"
    ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      DOCKER_HOST = "unix:///run/user/${uid}/docker.sock";
      XDG_RUNTIME_DIR = "/run/user/${uid}";
    };

    serviceConfig = {
      User = user;
      Type = "simple";
      Restart = "always";
      RestartSec = "5s";
      TimeoutStopSec = "30s";
      ExecStartPre = [
        "-${docker} rm -f hermes"
        "${docker} pull nousresearch/hermes-agent:latest"
      ];
      ExecStart = "${docker} run --rm --name hermes --add-host=host.docker.internal:host-gateway --volume hermes-data:/opt/data --env HERMES_UID=${uid} --env HERMES_GID=${gid} nousresearch/hermes-agent:latest sleep infinity";
      ExecStop = "-${docker} stop --time 30 hermes";
    };
  };

  # setSocketVariable makes Docker select richard's rootless daemon. The
  # alias attaches the host terminal to Hermes running inside that container.
  environment.shellAliases.hermes = "docker exec -it hermes hermes";
}
