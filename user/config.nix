
{
    allowBroken = true;
    allowUnfree = true;

    packageOverrides = super:

      let self = super.pkgs;
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
      inherit asciidoctor;
      };
}
