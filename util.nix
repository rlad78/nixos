lib: with lib; {
  selectFromAttrs = items: set: attrsets.filterAttrs (n: v: builtins.elem n items) set;
}
