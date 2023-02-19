{ packages, pkgs, release-mode ? false }:

let
  inherit (pkgs) lib callPackage;
  ohgradPkgs = packages.native;
  ohgradDrvs = lib.filterAttrs (_: value: lib.isDerivation value) ohgradPkgs;

  filterDrvs = inputs:
    lib.filter
      (drv:
        # we wanna filter our own packages so we don't build them when entering
        # the shell. They always have `pname`
        !(lib.hasAttr "pname" drv) ||
        drv.pname == null ||
        !(lib.any (name: name == drv.pname || name == drv.name) (lib.attrNames ohgradDrvs)))
      inputs;

in
with pkgs;

(mkShell {
  OCAMLRUNPARAM = "b";
  inputsFrom = lib.attrValues ohgradDrvs;
  buildInputs =
    (if release-mode then [
      cacert
      curl
      ocamlPackages.dune-release
      git
      opam
    ] else [ ]) ++
    (with ocamlPackages; [ ocaml-lsp merlin ocamlformat utop ]);
}).overrideAttrs (o: {
  propagatedBuildInputs = filterDrvs o.propagatedBuildInputs;
  buildInputs = filterDrvs o.buildInputs;
})
