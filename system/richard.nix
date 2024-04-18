{ config, pkgs, ... }:
{
  users.mutableUsers = false;

  # root settings
  users.users.root = {
    hashedPassword = "$6$vsOaxNJFEUCh3Z0K$2te0jZJfabO18pj58vXSr.J345ECzAZsUtCoHJL2NgZ/FE9m00Vt0asxXiX.aDWBtad./f5kelep1uVNjbeKE/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILrWTZFlFH6WAIzX0JWnCGyAnj8m5plOi5TdbhPVsDTF"
    ];
  };

  # richard settings
  users.users.richard = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    description = "Richard Lee Carter Jr";
    hashedPassword = "$6$SkIi1e6zfsLHIUvR$Xg3ZYvL5EsEh/jzcvHX2s6O0a5Z7RmyWRyeLGMMsh6XJnCcTZmrM4EC4N0n08WlIiJP2radM56K6UpLXvb122/";
    openssh.authorizedKeys.keys = [
       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKc2jzGXOAiQxBeec8qe8cqemg5O1/uCC/OWEDFJFvax richard@silverblue-go"
       "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILrWTZFlFH6WAIzX0JWnCGyAnj8m5plOi5TdbhPVsDTF"
    ];
  };
}
