# Local customization that won't be overridden by vagrant provision
{ config, lib, pkgs, ... }:

let geppetto = pkgs.eclipses.plugins.buildEclipseUpdateSite rec {
  name = "geppetto-4.3.1";
  version = "4.3.1-R201501182354";

  src = pkgs.fetchurl {
    url = "https://downloads.puppetlabs.com/geppetto/4.x/geppetto-linux.gtk.x86_64-${version}.zip";
    sha256= "1nlj47486ic4vj692wy83aba6h82q4ax3nfmmk79vvcalwg2yp9w";
  };

  meta = with lib; {
    homepage = http://puppetlabs.github.io/geppetto/;
    description = "An integrated toolset for developing Puppet modules and manifests";
    license = licenses.epl10;
    platforms = platforms.linux;
  };
};
in
{
  environment.systemPackages = with pkgs; [
    (eclipses.eclipseWithPlugins {
       eclipse = eclipses.eclipse-sdk-452;
       plugins = [ geppetto ];
     })
    # geany
  ];
}
