# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  scm_uri = "https://github.com/CIRB/devbox"
  scm_api = "https://api.github.com/repos/CIRB/devbox/releases"

  config.vm.box = "nixbox-1609c"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "2048"
	vb.customize ["modifyvm", :id, "--vram", "64"]
	vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
  end

  config.vm.provision "ssh-keys", type: "file", source: "ssh-keys", destination: "/tmp"

  config.vm.provision "system", args: [scm_uri, scm_api], type: "shell", name: "configure-system", inline: <<-SHELL
    ping -c1 8.8.8.8 > /dev/null
    if [[ $? -ne 0 ]]; then
      echo "No internet connexion. Exit";
      exit 1;
    fi
    scm_uri=$1
    scm_api=$2
    version="#{ENV['DEVBOX_WITH_VERSION']}"
    if [[ -z "${version}" ]]; then
      version="$(curl -s ${scm_api}/latest | jq -r .tag_name)"
    else
      echo "Overriding latest version";
    fi
    configdir="devbox-${version}"
    [[ -d "/tmp/system" ]] || mkdir /tmp/system
    if [[ ! -d "/tmp/system/${configdir}" ]]; then
      echo "Fetching ${version} configuration from ${scm_uri}";
      pushd /tmp/system > /dev/null;
      curl -s -L ${scm_uri}/archive/${version}.tar.gz | tar xz;
      cp --verbose "${configdir}/system/configuration.nix" "/etc/nixos/configuration.nix";
      cp --verbose -n "${configdir}/system/local-configuration.nix" "/etc/nixos/local-configuration.nix"
      popd > /dev/null;
    fi

    nixos-rebuild switch
  SHELL

  config.vm.provision "user", args: [scm_uri, scm_api], type: "shell" , name: "configure-user", privileged: false, inline: <<-SHELL
    ping -c1 8.8.8.8 > /dev/null
    if [[ $? -ne 0 ]]; then
      echo "No internet connexion. Exit";
      exit 1;
    fi
    scm_uri=$1
    scm_api=$2
    version="#{ENV['DEVBOX_WITH_VERSION']}"
    if [[ -z "${version}" ]]; then
      version="$(curl -s ${scm_api}/latest | jq -r .tag_name)"
    else
      echo "Overriding latest version";
    fi
    configdir="devbox-${version}"
    [[ -d "/tmp/user" ]] || mkdir /tmp/user
    if [[ ! -d "/tmp/user/${configdir}" ]]; then
      echo "Fetching ${version} configuration from ${scm_uri}";
      pushd /tmp/user > /dev/null;
      curl -s -L ${scm_uri}/archive/${version}.tar.gz | tar xz;
      pushd ${configdir}/user > /dev/null;
      chmod +x ./setenv.sh
      ./setenv.sh
      popd > /dev/null;
      popd > /dev/null;
    fi
  SHELL

end
