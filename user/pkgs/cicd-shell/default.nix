{ mkDerivation, base, lens, optional-args, process, raw-strings-qq
, stdenv, fetchgit, text, turtle, jq, pepper
}:
mkDerivation {
  pname = "cicd-shell";
  version = "0.9.9";
  src = fetchgit {
    url = "http://stash.cirb.lan/scm/cicd/cicd-shell.git";
    rev = "774ba6ef8ddaf2c9bb1ad5e6df047097443ecbbd";
    sha256 = "1q8v5hb5ny843djq1x4bs74mfry7qwq1flgb7i76zaqi4xg9rjfz";
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
