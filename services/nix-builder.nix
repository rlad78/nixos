{ config, pkgs, ... }:
let
  builder-username = "richard";
  secret-key-dir = "/home/${builder-username}/.k";
  setup-commands =
  ''\'
    sudo --user=${builder-username} \
    mkdir -p ${secret-key-dir}
    && sudo --user=${builder-username} \
    nix-store --generate-binary-cache-key ${builder-username} \
    ${secret-key-dir}/cache-priv-key.pem \
    ${secret-key-dir}/cache-pub-key.pem \
    && sudo nix sign-paths --all -k ${secret-key-dir}/cache-priv-key.pem
    \'
  '';

  nix-cmd = "nom";
  home-dir = config.users.users.richard.home;
  nix-dir = builtins.toString (home-dir + "/nixos");
  build-dir = toString (home-dir + "/builds");
  build-func =
    ''
      nxbuild() {
        screen -dmL -Logfile ${build-dir}/logs/''${1}_$(date -Iminutes) -S ''${1}-build zsh -c \
          "cd ${nix-dir} && ${nix-cmd} build --out-link ${build-dir}/''${1}_$(date -Iminutes) \
          --show-trace .#nixosConfigurations.''${1}.config.system.build.toplevel \
          && find ${build-dir} -mtime +7 -execdir rm -- '{}' \;" 
      }
    '';
in
{
  # users.users."${builder-username}" = {
    # isSystemUser = true;
    # createHome = true;
    # openssh.authorizedKeys.keys = [
       # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKc2jzGXOAiQxBeec8qe8cqemg5O1/uCC/OWEDFJFvax richard@silverblue-go"
       # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILrWTZFlFH6WAIzX0JWnCGyAnj8m5plOi5TdbhPVsDTF"
    # ];
  # };

  imports = [ ./sshd.nix ];

  services.openssh.settings = {
    PermitRootLogin = "yes";
    AllowUsers = [ "root" ];
  };

  environment = {
    systemPackages = [ nix-output-monitor ];
    shellAliases = {
      init-builder = setup-commands;
    };
  };

  programs.zsh.promptInit = build-func;

  nix.extraOptions =
    ''
      secret-key-files = /home/${builder-username}/.k/cache-priv-key.pem
    '';
  nix.settings.trusted-users = ["root" "richard" builder-username];

  systemd.tmpfiles.rules = [
    "d ${build-dir} 755 richard users"
    "d ${build-dir}/logs 755 richard users"
  ];
}
