with import <nixpkgs> {};

let xmonadEnv = haskellPackages.ghcWithPackages (p: with p; [xmonad xmonad-contrib]);
in
stdenv.mkDerivation rec {
  name = "devbox-dotfiles-${version}";
  version = "0.1";
  src = fetchFromGitHub {
      owner = "CIRB";
      repo = "devbox-dotfiles";
      rev = "4caed86088591940e58add1273d2ccd64add1ef0";
      sha256 = "1j5mb7zwcx842k3b1m3rxjc636q73q44rwm3959xn4psr8193i9c";
  };
  buildInput = [ xmonadEnv ];
  installPhase = ''
    ${xmonadEnv}/bin/ghc --make .xmonad/xmonad.hs -o .xmonad/xmonad-x86_64-linux
    cp -R ./. $out
  '';
}
