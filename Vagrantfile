# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  scm_uri = "https://github.com/CIRB/devbox"
  scm_api = "https://api.github.com/repos/CIRB/devbox/releases"

  config.vm.box = "nixbox-1603"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "2048"
	vb.customize ["modifyvm", :id, "--vram", "64"]
	vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
  end

  config.vm.provision "system", args: [scm_uri, scm_api], type: "shell", name: "configure-system", inline: <<-SHELL
    scm_uri=$1
    scm_api=$2
    grepexpr='(?<="tag_name":).*?[^\\\\](?=",)'
    _version=$(curl -s "${scm_api}/latest" | grep -oP "${grepexpr}")
    version="${_version#*\\"}"
    configdir="devbox-${version}"
    [[ -d "/tmp/system" ]] || mkdir /tmp/system
    [[ -d "/tmp/system/${configdir}" ]] || ( echo "fetching ${version} configuration from ${scm_uri}"; \
                                             pushd /tmp/system > /dev/null; \
                                             curl -s -L ${scm_uri}/archive/${version}.tar.gz | tar xz; \
                                             cp --verbose "${configdir}/configuration.nix" "/etc/nixos/configuration.nix"; \
                                             popd > /dev/null;
                                           )

    nixos-rebuild switch
  SHELL

  config.vm.provision "user", args: [scm_uri, scm_api], type: "shell" , name: "configure-user", privileged: false, inline: <<-SHELL
    scm_uri=$1
    scm_api=$2
    grepexpr='(?<="tag_name":).*?[^\\\\](?=",)'
    _version=$(curl -s "${scm_api}/latest" | grep -oP "${grepexpr}")
    version="${_version#*\\"}"
    configdir="devbox-${version}"
    [[ -d "/tmp/user" ]] || mkdir /tmp/user
    [[ -d "/tmp/user/${configdir}" ]] || ( echo "fetching ${version} configuration from ${scm_uri}"; \
                                           pushd /tmp/user > /dev/null; \
                                           curl -s -L ${scm_uri}/archive/${version}.tar.gz | tar xz; \
                                           cp "${configdir}/.xmobarrc" "${HOME}/.xmobarrc"; \
                                           cp "${configdir}/.wallpaper.jpg" "${HOME}/.wallpaper.jpg"; \
                                           mkdir -p "${HOME}/.xmonad"; \
                                           cp "${configdir}/xmonad.hs" "${HOME}/.xmonad/xmonad.hs"; \
					   mkdir -p "${HOME}/.config/xfce4/terminal"; \
					   cp "${configdir}/terminalrc" "${HOME}/.config/xfce4/terminal/terminalrc"; \
					   popd > /dev/null;
                                         )
  SHELL
end
