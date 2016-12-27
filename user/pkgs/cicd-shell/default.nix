{ mkDerivation, base, lens, optional-args, process, raw-strings-qq
, stdenv, fetchgit, text, turtle
}:
mkDerivation {
  pname = "cicd-shell";
  version = "0.9.2";
  src = fetchgit {
    url = "http://stash.cirb.lan/scm/cicd/cicd-shell.git";
    rev = "d13ff337a8ef8f0c812782f3c34e4c61e410ec27";
    sha256 = "0a36nb0aj8ym5ya4kggi3y543knnwpx33gfariaswdk662h8f614";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base lens optional-args process raw-strings-qq text turtle
  ];
  homepage = "ssh://git@stash.cirb.lan:7999/cicd/salt-shell.git";
  license = stdenv.lib.licenses.bsd3;
}
