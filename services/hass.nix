{ config, pkgs, secrets, ... }:
let
  hass_version = "2025.7";
in
{
  virtualisation.docker.enable = true;
  users.users.richard.extraGroups = [ "docker" ];

  users.groups.homeauto.name = "homeauto";

  users.users.hass = {
    isSystemUser = true;
    group = "homeauto";
  };

  systemd.tmpfiles.rules = [
    "d /hass 0750 hass homeauto"
    "d /hass/config 0750 hass homeauto"
    "d /hass/media 0750 hass homeauto"
    "d /hass/backups 0750 hass homeauto"
  ];

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    hass = {
      image = "homeassistant/home-assistant:${hass_version}";
      autoStart = true;
      volumes = [
        "/hass/config:/config"
        "/hass/media:/media"
        "/hass/backups:/backups"
        "/var/run/dbus:/var/run/dbus"
      ];
      extraOptions = [
        "--pull=always"
        "--network=host"
        "--cap-add=NET_RAW"
      ];
      environment = {
        TZ = "America/New_York";
      };
    };

    ws4kp = {
      image = "ghcr.io/netbymatt/ws4kp";
      autoStart = true;
      environment = {
        WSQS_hazards_checkbox = "true";
        WSQS_current_weather_checkbox = "true";
        WSQS_latest_observations_checkbox = "false";
        WSQS_hourly_checkbox = "true";
        WSQS_hourly_graph_checkbox = "true";
        WSQS_travel_checkbox = "false";
        WSQS_regional_forecast_checkbox = "false";
        WSQS_local_forecast_checkbox = "true";
        WSQS_extended_forecast_checkbox = "true";
        WSQS_almanac_checkbox = "true";
        WSQS_spc_outlook_checkbox = "true";
        WSQS_radar_checkbox = "true";
        WSQS_settings_wide_checkbox = "false";
        WSQS_settings_kiosk_checkbox = "true";
        WSQS_settings_scanLines_checkbox = "false";
        WSQS_settings_speed_select = "1.00";
        WSQS_settings_units_select = "us";
        WSQS_latLon = "{\"lat\":34.6886,\"lon\":-82.8348}";
      };
      ports = [ "4040:8080" ];
    };
  };

  services.mosquitto = {
    enable = true;
    logType = [ "all" ];
    listeners = [{
      users.hass.password = secrets.mqtt;
      users.z2m.password = secrets.z2m;
      acl = [
        "pattern readwrite #"
      ];
    }];
  };

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant = true;
      serial = {
        adapter = "ezsp";
        port = "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20220718182110-if00";
      };
      mqtt = {
        server = "mqtt://127.0.0.1:1883";
        user = "z2m";
        password = secrets.z2m;
        keepalive = 60;
        reject_unauthorized = true;
        version = 4;
      };
      frontend.port = 8099;
      advanced = {
        homeassistant_legacy_entity_attributes = false;
        legacy_api = false;
        legacy_availability_payload = false;
        log_level = "info";
      };
      device_options.legacy = false;
    };
  };

  networking.firewall.allowedTCPPorts = [
    8123 # hass webapp
    1883 # mqtt http
    1884 # mqtt http backup
    8099 # z2m frontend
    51827 # apple homekit
    5353 # apple homekit mdns
    4040 # ws4kp
  ];

  networking.firewall.allowedUDPPorts = [
    5353 # apple homekit mdns
  ];
}
