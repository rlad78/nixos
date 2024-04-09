{ config, pkgs, ... }:
{
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