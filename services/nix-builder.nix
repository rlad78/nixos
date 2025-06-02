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

  environment.shellAliases = {
    init-builder = setup-commands;
  };

  nix.extraOptions =
    ''
      secret-key-files = /home/${builder-username}/.k/cache-priv-key.pem
    '';
  nix.settings.trusted-users = ["root" "richard" builder-username];
}
