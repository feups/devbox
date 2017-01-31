{ mkDerivation, base, lens, optional-args, process, raw-strings-qq
, stdenv, fetchgit, text, turtle, jq, pepper
}:
mkDerivation {
  pname = "cicd-shell";
  version = "0.9.8";
  src = fetchgit {
    url = "http://stash.cirb.lan/scm/cicd/cicd-shell.git";
    rev = "0b1d8502be7ab94f368a6bada848730b0be1a777";
    sha256 = "0mqscwrvfls5aqxx72bdzbvyr580pmm5yy42d6czzlxc8crq0fcw";
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
