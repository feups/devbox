
{
    allowBroken = true;
    allowUnfree = true;

    packageOverrides = super:
      with import <nixpkgs/pkgs/development/haskell-modules/lib.nix> { pkgs = super; };

      let self = super.pkgs;
          haskellPackages = self.haskellPackages;
          hiera-eyaml-gpg = self.bundlerEnv rec {
            name = "hiera-eyaml-gpg-${version}";
            version = "0.6";

            gemfile = ./pkgs/hiera-eyaml-gpg/Gemfile;
            lockfile = ./pkgs/hiera-eyaml-gpg/Gemfile.lock;
            gemset = ./pkgs/hiera-eyaml-gpg/gemset.nix;

          };
          QuickCheck = haskellPackages.QuickCheck_2_9_2;
          quickcheck-instances = haskellPackages.quickcheck-instances.override { inherit QuickCheck; };
          http-api-data = (dontCheck haskellPackages.http-api-data_0_3_1).override {inherit QuickCheck quickcheck-instances; };
          servant = (dontCheck haskellPackages.servant_0_9).override {inherit http-api-data; };
          servant-client = (dontCheck haskellPackages.servant-client_0_9).override {inherit http-api-data servant;};
          language-puppet_1_3_3 = self.lib.overrideDerivation (haskellPackages.language-puppet.override {inherit servant servant-client;}) (super: rec {
            name = "language-puppet-${version}";
            version = "1.3.3";
            doCheck = false;
            doHaddock = false;
            src = self.fetchFromGitHub {
              rev    = "4125d27d9ec87cb0e63429a17d3a916e07023f15";
              owner  = "pierrer";
              repo   = "language-puppet";
              sha256 = "1l595fmypbr524hm07wlmrbx2xx3xfigcqs32aflamxv05gh4g2d";
            };
          });
          asciidoctor = self.bundlerEnv rec {
            name = "asciidoctor-${version}";
            version = "1.5.4";

            gemfile = ./pkgs/asciidoctor/Gemfile;
            lockfile = ./pkgs/asciidoctor/Gemfile.lock;
            gemset = ./pkgs/asciidoctor/gemset.nix;

            # Delete dependencies' executables
            postBuild = ''
              find $out/bin -type f -not -wholename '*bin/asciidoctor*' -print0 \
              | xargs -0 rm
            '';
          };
    in
    {
      inherit asciidoctor hiera-eyaml-gpg;
      haskellPackages = super.haskellPackages.override {
        overrides = self: super: {
          inherit language-puppet_1_3_3;
        };
      };
    };
}
