{ configs, pkgs, ... }:
{
  users.users.richard.packages = with pkgs; [
    dynamic-wallpaper
    bubblemail
    gnomeExtensions.bubblemail
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "com.mattjakeman.ExtensionManager"
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
