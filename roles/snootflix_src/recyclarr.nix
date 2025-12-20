{
  sonarr = {
    series = {
      base_url = "http://localhost:8989";
      api_key = "!env_var SONARR_API_KEY";
      include = [
        { template = "sonarr-quality-definition-series"; }
        { template = "sonarr-v4-quality-profile-web-1080p"; }
        { template = "sonarr-v4-custom-formats-web-1080p"; }
      ];
    };

    anime = {
      base_url = "http://localhost:8981";
      api_key = "";
      include = [
        { template = "sonarr-quality-definition-anime"; }
        { template = "sonarr-v4-quality-profile-anime"; }
        { template = "sonarr-v4-custom-formats-anime"; }
      ];
    };
  };

  radarr = {
    movies = {
      base_url = "http://localhost:7878";
      api_key = "!env_var RADARR_API_KEY";
      include = [
        { template = "radarr-quality-definition-movie"; }
        { template = "radarr-quality-profile-remux-web-1080p"; }
        { template = "radarr-custom-formats-remux-web-1080p"; }
      ];
    };
  };
}
