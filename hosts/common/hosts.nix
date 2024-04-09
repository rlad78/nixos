{ config, pkgs, lib, machine, me, ... }:
let
  cfg = config.arf.hosts;
  has-tail-ip = with lib.attrsets; filterAttrs (n: v: hasAttrByPath ["tail-ip"] v);
  tail-hosts = with lib.attrsets; concatMapAttrs (n: v: { ${v.tail-ip} = lib.lists.singleton n; } );
  has-local-only-ip = with lib.attrsets; filterAttrs (n: v: (hasAttr "local-ip" v) && !(hasAttr "tail-ip" v));
  local-hosts = with lib.attrsets; concatMapAttrs (n: v: { ${v.local-ip} = lib.lists.singleton n; } );
in
{
  options.arf.hosts.tailscale = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };
  
  networking.hosts = (
    lib.attrsets.optionalAttrs cfg.tailscale (tail-hosts (has-tail-ip (removeAttrs me.hosts [ machine.host ])))
    # also include non-tailscale hosts
    // (local-hosts (has-local-only-ip (removeAttrs me.hosts [ machine.host ])))
  );
}