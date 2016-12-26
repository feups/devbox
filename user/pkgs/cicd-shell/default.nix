{ mkDerivation, base, lens, optional-args, process, raw-strings-qq
, stdenv, fetchgit, text, turtle
}:
mkDerivation {
  pname = "cicd-shell";
  version = "0.9.1";
  src = fetchgit {
    url = "http://stash.cirb.lan/scm/cicd/cicd-shell.git";
    rev = "24eb1bc3c2240305bff2d2eedae8b5e9d7916d5e";
    sha256 = "1z0dx4fbxjxnpjbz8r1wzipmjq1p83bdvf3dzkv0kk029wpbhghb";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base lens optional-args process raw-strings-qq text turtle
  ];
  homepage = "ssh://git@stash.cirb.lan:7999/cicd/salt-shell.git";
  license = stdenv.lib.licenses.bsd3;
}
