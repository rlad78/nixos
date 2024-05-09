{ config, pkgs, lib, hosts, mkPoetryScriptsPackage, ... }:
let
  mnt-prefix = "mediadisk";
  mergerfs-dir = "/snoot";

  disks-by-uuid = with lib.lists; forEach  [
    "3b5ccd1e-00ea-4dac-b27f-1c7822c737c4"
    "2f2168da-b5d0-4b06-bbb4-e70b042a412f"
    "feea2c5b-65c4-4368-8960-ca84fcaf1d42"
    "ba7fc5c0-df48-4a5a-b20a-7e0b653b6060"
  ] (x: "/dev/disk/by-uuid/${x}");

  # -----

  disks-with-mnt = with lib; lists.zipListsWith (
    a: b: {mnt = "/mnt/${mnt-prefix}${builtins.toString b}"; uuid = a;}
  ) disks-by-uuid (lists.range 1 (builtins.length disks-by-uuid));

  my-device-ips = with lib; lists.unique (lists.flatten (
    builtins.map (a: attrsets.attrValues a) (
      builtins.map (x: attrsets.filterAttrs (
        n: v: builtins.elem n [ "tail-ip" "local-ip" ]) x) (
          builtins.attrValues hosts)
      )
    )
  );

  # buildarr-src = pkgs.fetchFromGitHub {
    # owner = "buildarr";
    # repo = "buildarr";
    # rev = "093bd02e8269e05b8c5c56cffa756a9b549ebccc";
    # hash = "sha256-it5zrpsf6ybBznXgs8I9El1tArV9m5jKkQ7R0yBiDFc=";
  # };
#
  # buildarr = mkPoetryScriptsPackage {
    # projectDir = buildarr-src;
    # python = pkgs.python311;
  # };

  validators-pypi = {
    buildPythonPackage,
    fetchPypi,
    setuptools,
  }: ( buildPythonPackage rec {
    pname = "validators";
    version = "0.22.0";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-d7Jomxcu7rYA2WBauGGUZBZwzbc7YK/VdxQqk5eHM3A=";
    };
    doCheck = false;
    pyproject = true;
    build-system = [ setuptools ];
  });

  validators = pkgs.python311Packages.callPackage validators-pypi {};

  click-params-pypi = {
    buildPythonPackage,
    fetchPypi,
    poetry-core,
    click,
    # validators,
    deprecated
  }: ( buildPythonPackage rec {
    pname = "click_params";
    version = "0.5.0";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-X+l7lFl4GjtDuE/k7ABlGT4bDVz23HeJf+IMMfR41/8=";
    };
    doCheck = false;
    pyproject = true;
    build-system = [ poetry-core ];
    propagatedBuildInputs = [
      click
      validators
      deprecated
    ];
  });

  click-params = pkgs.python311Packages.callPackage click-params-pypi {};

  # pydantic-pypi = {
    # buildPythonPackage,
    # fetchPypi,
    # setuptools,
    # devtools,
    # email-validator,
    # typing-extensions,
    # python-dotenv
  # }: ( buildPythonPackage rec {
    # pname = "pydantic";
    # version = "1.10.10";
    # src = fetchPypi {
      # inherit pname version;
      # hash = "sha256-O41b2XiG+etZJgWUIHyfV9zhSm+GnGzuqQGIcV0pkho=";
    # };
    # doCheck = false;
    # pyproject = false;
    # build-system = [ setuptools ];
    # propagatedBuildInputs = [
      # devtools
      # email-validator
      # typing-extensions
      # python-dotenv
    # ];
  # });
#
  # pydantic = pkgs.python311Packages.callPackage pydantic-pypi {};

  buildarr-pypi = { 
    buildPythonApplication, 
    fetchPypi, 
    setuptools, 
    setuptools-scm, 
    poetry-core,
    aenum,
    click,
    # click-params,
    importlib-metadata,
    pydantic_1,
    pyyaml,
    requests,
    schedule,
    stevedore,
    watchdog,
  }: ( buildPythonApplication rec {
    pname = "buildarr";
    version = "0.7.1";
    src = fetchPypi {
      inherit pname version;
      hash = "sha256-FmYFChehwNYK7D+wBujuEBl02SxdKD7UBC7jGReeqnM==";
    };
    doCheck = false;
    pyproject = true;
    build-system = [
      setuptools
      setuptools-scm
      poetry-core
    ];
    propagatedBuildInputs = [
      aenum
      click
      click-params
      importlib-metadata
      pydantic_1
      pyyaml
      requests
      schedule
      stevedore
      watchdog
    ];
  });
in
{
  nixarr = {
    enable = true;
    mediaUsers = [ "richard" ];
    mediaDir = mergerfs-dir;
    stateDir = "/config";
    additionalMediaSubdirs = [ "anime" ];
    # sabnzbd = {
      # enable = true;
      # openFirewall = true;
      # whitelistRanges = [ "10.0.0.0/23" "100.64.0.0/10" ];
    # };
    sonarr.enable = true;
    radarr.enable = true;
    prowlarr.enable = true;
    transmission = {
      enable = true;
      extraAllowedIps = my-device-ips;
      flood.enable = true;
    };
  };

  # users.users.richard.extraGroups = [ "media" ];

  services.plex = {
    enable = true;
    user = "streamer";
    group = "media";
    dataDir = "${config.nixarr.stateDir}/plex";
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d ${config.services.plex.dataDir} 0770 streamer media"
    "d ${mergerfs-dir} 0770 root media"
    # "d ${mergerfs-dir}/library/anime 0770 streamer media"
  ];

  # drive management
  environment.systemPackages = with pkgs; [
    mergerfs
    mergerfs-tools
    recyclarr
    # (python311.withPackages (python-pkgs: [
      (python311Packages.callPackage buildarr-pypi {})
    # ]))
  ];

  fileSystems = with lib; attrsets.mergeAttrsList (
    builtins.map (x: {${x.mnt} = {
      device = x.uuid;
      fsType = "ext4";
      options = [ "defaults" "nofail" ];
    };}) disks-with-mnt
  ) // {
    ${mergerfs-dir} = {
      fsType = "fuse.mergerfs";
      device = "/mnt/${mnt-prefix}*";
      noCheck = true;
      options = [ "defaults" "nofail" "nonempty" "allow_other" "use_ino" "minfreespace=100M" "category.create=mspmfs" ];
    };
  };
}

