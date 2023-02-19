{ stdenv, lib, ocamlPackages, static ? false, doCheck, nix-filter }:

with ocamlPackages;

rec {
  camlpdfExample = buildDunePackage {
    pname = "camlpdf-example";
    version = "0.0.1-dev";

    src = with nix-filter; filter {
      root = ./.;
      include = [
        "dune-project"
        "src"
        "stenograf.pdf"
      ];
    };

    useDune2 = true;

    nativeBuildInputs = [ ocaml dune findlib ];
    propagatedBuildInputs = [
      camlpdf
    ];
    inherit doCheck;

    meta = {
      description = "A simple example of pdf parsing using camlpdf";
      license = lib.licenses.mit;
    };
  };
}
