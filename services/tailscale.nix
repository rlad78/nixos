{ config, pkgs, lib, uncommon, me, ... }:

let
  has-tail-ip = with lib.attrsets; filterAttrs (n: v: hasAttrByPath ["tail-ip"] v);
  tail-hosts = with lib.attrsets; concatMapAttrs (n: v: { ${v.tail-ip} = lib.lists.singleton n; } );
  has-local-only-ip = with lib.attrsets; filterAttrs (n: v: (hasAttr "local-ip" v) && !(hasAttr "tail-ip" v));
  local-hosts = with lib.attrsets; concatMapAttrs (n: v: { ${v.local-ip} = lib.lists.singleton n; } );
in
{
  services.tailscale.enable = true;
  services.tailscale.port = 41641;
  environment.systemPackages = with pkgs; [ tailscale ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  networking.firewall.allowedUDPPorts = [ 41641 ];

  networking.hosts = (
    tail-hosts (has-tail-ip (removeAttrs me.hosts [ uncommon.host ])) 
    # also include non-tailscale hosts
    // (local-hosts (has-local-only-ip (removeAttrs me.hosts [ uncommon.host ])))
  );
}
