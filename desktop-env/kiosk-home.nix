{ pkgs, statever, ... }:
{
  programs.home-manager.enable = true;

  home = {
    username = "kiosk";
    homeDirectory = "/home/kiosk";
    stateVersion = statever;
    packages = with pkgs; [
      light
    ];
  };

  services.swayidle = {
    enable = true;
    timeouts =
      let
        set_light = n: "${pkgs.light}/bin/light -S ${builtins.toString n}";
        default_light = 5;
        dim_light = 1;
      in
      [
        {
          timeout = 45;
          command = set_light dim_light;
          resumeCommand = set_light default_light;
        }
        {
          timeout = 60;
          command = set_light 0;
          resumeCommand = set_light default_light;
        }
      ];
  };
}
