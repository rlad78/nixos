{
  sonarr = {
    series = {
      base_url = "http://localhost:8989";
      api_key = "!env_var SONARR_API_KEY";
    };

    anime = {
      base_url = "http://localhost:8981";
      api_key = "";
    };
  };

  radarr = {
    movies = {
      base_url = "http://localhost:7878";
      api_key = "!env_var RADARR_API_KEY";
    };
  };
}
