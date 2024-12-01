with (import ../depot { }).third_party.nixpkgs;

mkShell {
  buildInputs = [
    (pkgs.runCommand "swipl-prolog" { } ''
      mkdir -p $out/bin
      ln -s ${swiProlog}/bin/* $out/bin/
      ln -s ${swiProlog}/bin/swipl $out/bin/prolog
    '')
  ];
}
