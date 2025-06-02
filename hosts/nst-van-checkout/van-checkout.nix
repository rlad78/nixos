{ pkgs, ... }:
{
  systemd.user.services.nst-van-checkout = {
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.firefox}/bin/firefox -kiosk http://vcheckout.nst.clemson.edu:3000/";
    };
  };
}