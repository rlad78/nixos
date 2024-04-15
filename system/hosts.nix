{ config, pkgs, lib, hosts, ... }:
let
  cfg = config.arf.hosts;
  has-tail-ip = with lib.attrsets; filterAttrs (n: v: hasAttrByPath ["tail-ip"] v);
  tail-hosts = with lib.attrsets; concatMapAttrs (n: v: { ${v.tail-ip} = lib.lists.singleton n; } );
  has-local-only-ip = with lib.attrsets; filterAttrs (n: v: (hasAttr "local-ip" v) && !(hasAttr "tail-ip" v));
  local-hosts = with lib.attrsets; concatMapAttrs (n: v: { ${v.local-ip} = lib.lists.singleton n; } );
in
{
  options.arf.hosts.tailscale = with lib; mkOption {
    type = types.bool;
    default = true;
  };
  
  config = {
    networking.hosts = (
      lib.attrsets.optionalAttrs cfg.tailscale (tail-hosts (has-tail-ip (removeAttrs hosts [ config.networking.hostName ])))
      # also include non-tailscale hosts
      // (local-hosts (has-local-only-ip (removeAttrs hosts [ config.networking.hostName ])))
    );
  };
}