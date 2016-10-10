#! /usr/bin/env bash

eclipse_version='4.5.2'

if [[ -f "/vagrant/params.sh" ]]; then
    source /vagrant/params.sh
else
    source ./params.sh
fi

eclipse_plugins=${eclipse_plugins:=false}
eclipse_geppetto=${eclipse_geppetto:=false}
mr_template_repo_url=${mr_template_repo_url:="git://github.com/CIRB/vcsh_mr_template.git"}

# dotfiles for which a custom source repo can be specified in dotfiles.nix
function install_dotfiles {
    echo "Installing dotfiles"
    if ! [[ -f $HOME/.mrconfig ]]; then
        echo "About to clone ${mr_template_repo_url}"
        vcsh clone "$mr_template_repo_url"  mr
        mr -f -d "$HOME" up
    else
        mr -d "$HOME" up
    fi
}

# Shared common files that will be overridden when provisioning a new configuration
function install_commonfiles {
    echo "Installing common files"

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

function install_eclipse_plugin {
    local qualified_name=$1
    local repository=${2:-"http://download.eclipse.org/releases/mars/"}
    for f in ${HOME}/.eclipse/org.eclipse.platform_${eclipse_version}/plugins/${qualified_name}*; do
        if ! [ -e "$f" ]; then
            echo "About to download Eclipse ${qualified_name}. Hold on."
            eclipse -application org.eclipse.equinox.p2.director \
                    -repository "$repository" \
                    -installIU "${qualified_name}.feature.feature.group" \
                    -tag InitialState \
                    -profile SDKProfile \
                    -profileProperties org.eclipse.update.install.features=true \
                    -p2.os linux \
                    -p2.ws gtk \
                    -p2.arch x86 \
                    -roaming \
                    -nosplash
        fi
        break
    done
}

####     Main ####
echo     "Configuring user"

install_pk_keys
install_dotfiles
install_commonfiles
if $eclipse_plugins; then
    if $eclipse_geppetto; then
        install_eclipse_plugin "com.puppetlabs.geppetto" "http://geppetto-updates.puppetlabs.com/4.x"
    fi
    install_eclipse_plugin "org.eclipse.m2e"
    install_eclipse_plugin "org.eclipse.egit"
fi
