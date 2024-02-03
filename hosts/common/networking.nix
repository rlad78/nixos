{ config, pkgs, lib, machine, me, ... }:
let
  has-tail-ip = with lib.attrsets; filterAttrs (n: v: hasAttrByPath ["tail-ip"] v);
  tail-hosts = with lib.attrsets; concatMapAttrs (n: v: { ${v.tail-ip} = lib.lists.singleton n; } );
  has-local-only-ip = with lib.attrsets; filterAttrs (n: v: (hasAttr "local-ip" v) && !(hasAttr "tail-ip" v));
  local-hosts = with lib.attrsets; concatMapAttrs (n: v: { ${v.local-ip} = lib.lists.singleton n; } );
in
{
  networking.hosts = (
    tail-hosts (has-tail-ip (removeAttrs me.hosts [ machine.host ])) 
    # also include non-tailscale hosts
    // (local-hosts (has-local-only-ip (removeAttrs me.hosts [ machine.host ])))
  );

  programs.ssh.kexAlgorithms = [
    # default
    "sntrup761x25519-sha512@openssh.com"
    "curve25519-sha256"
    "curve25519-sha256@libssh.org"
    "ecdh-sha2-nistp256"
    "ecdh-sha2-nistp384"
    "ecdh-sha2-nistp521"
    "diffie-hellman-group-exchange-sha256"
    "diffie-hellman-group16-sha512"
    "diffie-hellman-group18-sha512"
    "diffie-hellman-group14-sha256"
    "kex-strict-c-v00@openssh.com"

    # needed for older cisco switches
    "diffie-hellman-group-exchange-sha1"
  ];

  programs.ssh.hostKeyAlgorithms = [
    # default
    "ssh-ed25519-cert-v01@openssh.com"
    "ecdsa-sha2-nistp256-cert-v01@openssh.com"
    "ecdsa-sha2-nistp384-cert-v01@openssh.com"
    "ecdsa-sha2-nistp521-cert-v01@openssh.com"
    "sk-ssh-ed25519-cert-v01@openssh.com"
    "sk-ecdsa-sha2-nistp256-cert-v01@openssh.com"
    "rsa-sha2-512-cert-v01@openssh.com"
    "rsa-sha2-256-cert-v01@openssh.com"
    "ssh-ed25519"
    "ecdsa-sha2-nistp256"
    "ecdsa-sha2-nistp384"
    "ecdsa-sha2-nistp521"
    "sk-ssh-ed25519@openssh.com"
    "sk-ecdsa-sha2-nistp256@openssh.com"
    "rsa-sha2-512"
    "rsa-sha2-256"

    # needed for older cisco switches
    "ssh-rsa"
  ];
}