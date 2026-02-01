{ lib, secrets, ... }:
let
  dir-settings = {
    user = "terraria";
    group = "terraria";
    mode = "0770";
  };
  terraria-dirs = [
    "/terraria"
    "/terraria/data"
    "/terraria/worlds"
  ];
in
{
  systemd.tmpfiles.settings."50-terraria" = (
    lib.attrsets.genAttrs terraria-dirs (dir: {d = dir-settings;})
  );

  services.terraria = {
    enable = true;
    port = 5969;
    openFirewall = true;
    noUPnP = true;

    dataDir = "/terraria/data";
    worldPath = "/terraria/worlds/main.wld";
    autoCreatedWorldSize = "medium";
    
    secure = true;
    password = secrets.terraria;
    messageOfTheDay = "yo yo yo";
  };
}
