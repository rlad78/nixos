{ configs, pkgs, ... }:
let
  gnome-extensions = with pkgs.gnomeExtensions; [
    # bubblemail
    auto-power-profile
    caffeine
    runcat
    night-theme-switcher
    paperwm
    search-light
    no-overview
    grand-theft-focus
  ];
in
{
  users.users.richard.packages = with pkgs; [
    dynamic-wallpaper
    # bubblemail
  ] ++ gnome-extensions;

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;

  services.flatpak.packages = [
    "com.mattjakeman.ExtensionManager"
  ];

  # systemd.user.services.bubblemail = {
    # enable = true;
    # description = "Start bubblemaild service";
    # serviceConfig = {
      # Type = "oneshot";
      # RemainAfterExit = true;
      # StandardOutput = "journal";
      # ExecStart = "${pkgs.bubblemail}/bin/bubblemaild";
    # };
    # wantedBy = [ "default.target" ];
  # };
}
