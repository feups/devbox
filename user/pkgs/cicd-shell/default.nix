{ mkDerivation, base, lens, optional-args, process, raw-strings-qq
, stdenv, fetchgit, text, turtle
}:
mkDerivation {
  pname = "cicd-shell";
  version = "0.9.4";
  src = fetchgit {
    url = "http://stash.cirb.lan/scm/cicd/cicd-shell.git";
    rev = "73cd191d8e36ec939f8807eebd057bf8c6d802d0";
    sha256 = "1a4zxba9ck51j2b24bz8vvamh079953q41i6zarkxf0c0wgdpzl3";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base lens optional-args process raw-strings-qq text turtle
  ];
  homepage = "ssh://git@stash.cirb.lan:7999/cicd/salt-shell.git";
  license = stdenv.lib.licenses.bsd3;
}
