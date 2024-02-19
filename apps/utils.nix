{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    bitwarden
    bubblemail
    gnomeExtensions.bubblemail
  ];

  services.flatpak.packages = [
    "com.github.tchx84.Flatseal"
    "com.cassidyjames.butler"
  ];

  systemd.user.services.bubblemail = {
    enable = true;
    description = "Start bubblemaild service";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal";
      ExecStart = "${pkgs.bubblemail}/bin/bubblemaild";
    };
    wantedBy = [ "default.target" ];
  };
}
