#! /usr/bin/env bash

# dotfiles for which a custom source repo can be specified in dotfiles.nix
function install_dotfiles {
    echo "Installing dotfiles"
    if ! [[ -f $HOME/.mrconfig ]]; then
        vcsh clone git://github.com/CIRB/vcsh_mr_template.git mr
    fi
    mr -d "$HOME" up
}

# Shared common files that will be overridden when provisioning a new configuration
function install_commonfiles {
    echo "Installing common files"

    cp .wallpaper.jpg "${HOME}/.wallpaper.jpg";

    install -Dm644 config.nix "${HOME}/.nixpkgs/config.nix";
    cp -r pkgs "${HOME}/.nixpkgs/"
}

function install_pk_keys {
    if ! [[ -d /vagrant/ssh-keys ]]; then
        echo "No ssh-keys directory found. Will abort user provisioning."
        exit 1
    fi
    cp ssh-config "${HOME}/.ssh/config";
    if [[ -f /vagrant/ssh-keys/config_mygithub ]]; then
        # in case of 'vagrant destroy' re-use saved config_mygithub file
        cp --verbose -n /vagrant/ssh-keys/config_mygithub "${HOME}/.ssh/config_mygithub"
    fi
    echo "Installing PK keys"
    rsync --chmod=644 /vagrant/ssh-keys/*.pub "${HOME}/.ssh/"
    for f in $(find /vagrant/ssh-keys -maxdepth 1 -type f ! -name "*.*" ); do
        rsync --chmod=600  "${f}" "${HOME}/.ssh/"
    done
}

function install_projects {

    local cicd_dir="${HOME}/projects/cicd"
    if ! [[ -d "$cicd_dir" ]]; then
        ping -c1 stash.cirb.lan > /dev/null
        if [[ $? -ne 0 ]]; then
            echo "Cannot create cicd projects. No Bitbucket connexion."
            exit 1;
        fi
        echo "Installing project files"
        mkdir -p "$cicd_dir"
        pushd "$cicd_dir" > /dev/null
        git clone ssh://git@stash.cirb.lan:7999/cicd/puppet-stack-management.git puppet
        popd
    fi
}

function install_eclipse_plugins {
    if ! [[ -d "${HOME}/.eclipse/org.eclipse.platform_4.5.2/p2" ]]; then
        echo "Installing eclipse plugins"

        # puppet
        eclipse -application org.eclipse.equinox.p2.director \
                -repository http://geppetto-updates.puppetlabs.com/4.x \
                -installIU com.puppetlabs.geppetto.feature.group \
                -tag InitialState \
                -profile SDKProfile \
                -profileProperties org.eclipse.update.install.features=true \
                -p2.os linux \
                -p2.ws gtk \
                -p2.arch x86 \
                -roaming \
                -nosplash

        # maven
        eclipse -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/mars/ -installIU org.eclipse.m2e.feature.feature.group \
                -tag InitialState \
                -profile SDKProfile \
                -profileProperties org.eclipse.update.install.features=true \
                -p2.os linux \
                -p2.ws gtk \
                -p2.arch x86 \
                -roaming \
                -nosplash

        # git
        eclipse -application org.eclipse.equinox.p2.director -repository http://download.eclipse.org/releases/mars/ -installIU org.eclipse.egit.feature.group \
                -tag InitialState \
                -profile SDKProfile \
                -profileProperties org.eclipse.update.install.features=true \
                -p2.os linux \
                -p2.ws gtk \
                -p2.arch x86 \
                -roaming \
                -nosplash
    fi
}

####     Main ####
echo     "Configuring user"

install_pk_keys
install_dotfiles
install_commonfiles
install_eclipse_plugins
install_projects
