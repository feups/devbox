{ mkDerivation, base, lens, optional-args, process, raw-strings-qq
, stdenv, fetchgit, text, turtle, jq, pepper
}:
mkDerivation {
  pname = "cicd-shell";
  version = "0.9.7";
  src = fetchgit {
    url = "http://stash.cirb.lan/scm/cicd/cicd-shell.git";
    rev = "a7299839cb504753f8bf2ca7fe932f3a9f36ab01";
    sha256 = "0bxqar03c5ckzf1jv8b0pdqhbr176xd6zcmmamkvglw98i4ygag5";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base lens optional-args process raw-strings-qq text turtle
  ];
  executableSystemDepends = [ jq pepper ];
  homepage = "ssh://git@stash.cirb.lan:7999/cicd/salt-shell.git";
  license = stdenv.lib.licenses.bsd3;
}
