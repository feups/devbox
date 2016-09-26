#! /usr/bin/env bash

# dotfiles for which a custom source repo can be specified in dotfiles.nix
function install_dotfiles {
    echo "Installing dotfiles"
    nix-build dotfiles.nix -o dotfiles
    stow dotfiles -v -t "$HOME"
}

# Shared common files that will be overridden when provisioning a new configuration
function install_commonfiles {
    echo "Installing common files"

    cp .wallpaper.jpg "${HOME}/.wallpaper.jpg";

    install -Dm644 config.nix "${HOME}/.nixpkgs/config.nix";
    cp -r pkgs "${HOME}/.nixpkgs/"
}

function install_pk_keys {
    echo "Installing PK keys"
    cp ssh-config "${HOME}/.ssh/config";
    private_keys=$(find /tmp/ssh-keys -maxdepth 1 -type f ! -name "*.*" )
    rsync --remove-source-files --chmod=ugo-x /tmp/ssh-keys/*.pub "${HOME}/.ssh/"
    rsync --chmod=go-rw  "$private_keys" "${HOME}/.ssh/"
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
}

#### Main ####
echo "Configuring user"

install_dotfiles
install_commonfiles
install_pk_keys
install_eclipse_plugins
install_projects
