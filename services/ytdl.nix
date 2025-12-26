{ config, lib, pkgs, pkgs-unstable, ... }:
with lib; let
  cfg = config.arf.ytdl;

  scriptNames = [
    "Unique"
    "Unique_Recent"
    "Playlists"
  ];
in
{
  options.arf.ytdl = {
    enable = mkEnableOption "Enable yt-dlp download setup";

    workingDir = mkOption {
      type = types.path;
      default = /yt;
    };
  };

  config = let
    sourceDir = ./src/ytdl;
    targetDir = toString cfg.workingDir;

    sh-to-store = scriptName: (pkgs.writeTextFile {
      name = "${scriptName}.sh";
      executable = true;
      text = builtins.readFile (sourceDir + "/${scriptName}.sh");
    });

    tmpfiles-symlink-script = scriptName: (
      "L ${targetDir}/${scriptName}.sh - - - - ${sh-to-store scriptName}"
    );

    tmpfiles-source-file = scriptName: (
      "f \"${targetDir}/Source - ${builtins.replaceStrings ["_"] [" "] scriptName}.txt\" 0640 richard storage - -"
    );

    scriptSymlinkTmpfiles = lists.forEach scriptNames (x: tmpfiles-symlink-script x);
    sourceFileTmpfiles = lists.forEach scriptNames (x: tmpfiles-source-file x);

    cookiesInfoFile = pkgs.writeTextFile {
      name = "how_to_get_cookies.md";
      text = builtins.readFile (sourceDir + "/how_to_get_cookies.md");
    };
  in mkIf cfg.enable {
    environment.systemPackages = with pkgs-unstable; [
      yt-dlp
      ffmpeg
    ];

    systemd.tmpfiles.rules = [
      "d ${targetDir} 0750 richard storage - -"
      "L ${targetDir}/how_to_get_cookies.md - - - - ${cookiesInfoFile}"
    ] ++ scriptSymlinkTmpfiles ++ sourceFileTmpfiles;
  };
}
