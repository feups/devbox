{ mkDerivation, base, lens, optional-args, process, raw-strings-qq
, stdenv, fetchgit, text, turtle
}:
mkDerivation {
  pname = "cicd-shell";
  version = "0.9.3";
  src = fetchgit {
    url = "http://stash.cirb.lan/scm/cicd/cicd-shell.git";
    rev = "cf93f27631640d5efc7b54c615b023d097c5e5ba";
    sha256 = "04k431hngnb94h5d73s6lgpw1lhzq4lq6r8yvpj21zy4c7zd5fmi";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base lens optional-args process raw-strings-qq text turtle
  ];
  homepage = "ssh://git@stash.cirb.lan:7999/cicd/salt-shell.git";
  license = stdenv.lib.licenses.bsd3;
}
