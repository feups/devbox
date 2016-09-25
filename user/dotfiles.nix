with import <nixpkgs> {};

let xmonadEnv = haskellPackages.ghcWithPackages (p: with p; [xmonad xmonad-contrib]);
in
stdenv.mkDerivation rec {
  name = "devbox-dotfiles-${version}";
  version = "0.1";
  src = fetchFromGitHub {
      owner = "CIRB";
      repo = "devbox-dotfiles";
      rev = "801f66f3c7d657f5648963c60e89743d85133b1a" ;
      sha256 = "1w4vaqp21dmdd1m5akmzq4c3alabyn0mp94s6lqzzp1qpla0sdx0" ;
  };
  buildInput = [ xmonadEnv ];
  installPhase = ''
    ${xmonadEnv}/bin/ghc --make .xmonad/xmonad.hs -o .xmonad/xmonad-x86_64-linux
    cp -R ./. $out
  '';
}
