
{
    allowBroken = true;
    allowUnfree = true;

    packageOverrides = super:

      let self = super.pkgs;
          hiera-eyaml-gpg = self.bundlerEnv rec {
            name = "hiera-eyaml-gpg-${version}";
            version = "0.6";

            gemfile = ./pkgs/hiera-eyaml-gpg/Gemfile;
            lockfile = ./pkgs/hiera-eyaml-gpg/Gemfile.lock;
            gemset = ./pkgs/hiera-eyaml-gpg/gemset.nix;

          };
          puppet-env = self.bundlerEnv rec {
            name = "puppet-env-${version}";
            version = "4.7.0";

            gemfile = ./pkgs/puppet-env/Gemfile;
            lockfile = ./pkgs/puppet-env/Gemfile.lock;
            gemset = ./pkgs/puppet-env/gemset.nix;
          };
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
      inherit asciidoctor hiera-eyaml-gpg puppet-env;
      };
}
