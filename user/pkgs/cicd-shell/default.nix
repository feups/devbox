{ mkDerivation, base, lens, optional-args, process, raw-strings-qq
, stdenv, fetchgit, text, turtle, jq, pepper
}:
mkDerivation {
  pname = "cicd-shell";
  version = "0.9.8";
  src = fetchgit {
    url = "http://stash.cirb.lan/scm/cicd/cicd-shell.git";
    rev = "ed35ffad59e2f9607b38e25c0befa6496e95c2d2";
    sha256 = "0vmfp9324vgaz8jnvsajs1s3hq1dylz2ldhhszmp8ai6fyvh0lp4";
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
