{ mkDerivation, base, lens, optional-args, process, raw-strings-qq
, stdenv, fetchgit, text, turtle
}:
mkDerivation {
  pname = "cicd-shell";
  version = "0.9.6";
  src = fetchgit {
    url = "http://stash.cirb.lan/scm/cicd/cicd-shell.git";
    rev = "a5a61ff743dfe96391531053c646c41071fb8f45";
    sha256 = "153mziydwk44klgjs7kpmnnjm90191c0b65q0mf750gvml643j33";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base lens optional-args process raw-strings-qq text turtle
  ];
  homepage = "ssh://git@stash.cirb.lan:7999/cicd/salt-shell.git";
  license = stdenv.lib.licenses.bsd3;
}
