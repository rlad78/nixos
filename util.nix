lib: with lib; {
  selectFromAttrs = items: set: attrsets.filterAttrs (n: v: builtins.elem n items) set;
  gatherAllHostIPs =
    hosts:
    lists.unique (
      lists.flatten (
        map (a: attrsets.attrValues a) (
          map (
            x:
            attrsets.filterAttrs (
              n: v:
              builtins.elem n [
                "tail-ip"
                "local-ip"
              ]
            ) x
          ) (builtins.attrValues hosts)
        )
      )
    );
}
