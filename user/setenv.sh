#! /usr/bin/env bash

eclipse_version='4.5.2'
export nixpkgs_ref="65830800bdaac91eae965d16df4473fc2a698fca" # http://hydra.nixos.org/build/45387163

if [[ -f "/vagrant/params.sh" ]]; then
    source /vagrant/params.sh
else
    source user/params.sh
fi

eclipse_plugins=${eclipse_plugins:=false}
eclipse_geppetto=${eclipse_geppetto:=false}
mr_template_repo_url=${mr_template_repo_url:="git://github.com/CIRB/vcsh_mr_template.git"}

function setupEnvConfig {
   if [[ -n "$user_name" ]]; then
       git config --global user.name "$user_name"
   fi
   if [[ -n "$user_email" ]]; then
       git config --global user.email "$user_email"
   fi
   if [[ -n "$user_id" ]]; then
       echo user_id >> $HOME/.user_id
   fi
   if [[ -n "$user_pwd" ]]; then
       echo user_pwd >> $HOME/.user_pwd
   fi
   if [[ -n "$user_stack" ]]; then
       echo user_stack >> $HOME/.user_stack
   fi
   echo nixpkgs_ref >> $HOME/.nixpkgs_ref
}

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
    echo "Installing nixpkgs files"

    install -Dm644 user/config.nix "${HOME}/.nixpkgs/config.nix";
    cp -r user/pkgs "${HOME}/.nixpkgs/"

    echo "Installing doc files"
    curl -s http://stash.cirb.lan/projects/CICD/repos/puppet-shared-scripts/raw/README.adoc?at=refs/heads/master > puppet.adoc
    curl -s http://stash.cirb.lan/projects/CICD/repos/cicd-shell/raw/README.adoc?at=refs/heads/master > cicd-shell.adoc
    make doc
    install -Dm644 doc/devbox.html "${HOME}/.local/share/doc/devbox.html"
    install -Dm644 doc/devbox.pdf "${HOME}/.local/share/doc/devbox.pdf"
}

function install_pk_keys {
    if ! [[ -d /vagrant/ssh-keys ]]; then
        echo "No ssh-keys directory found. Will abort user provisioning."
        exit 1
    fi
    cp user/ssh-config "${HOME}/.ssh/config";
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
    local install_name=${3:-"${1}.feature.group"}
    for f in ${HOME}/.eclipse/org.eclipse.platform_${eclipse_version}/plugins/${qualified_name}*; do
        if ! [ -e "$f" ]; then
            echo "About to download Eclipse ${qualified_name}. Hold on."
            eclipse -application org.eclipse.equinox.p2.director \
                    -repository "$repository" \
                    -installIU "${install_name}" \
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
    install_eclipse_plugin "org.eclipse.egit"
    install_eclipse_plugin "org.eclipse.m2e" "http://download.eclipse.org/releases/mars/" "org.eclipse.m2e.feature.feature.group"
    if $eclipse_geppetto; then
        install_eclipse_plugin "com.puppetlabs.geppetto" "http://geppetto-updates.puppetlabs.com/4.x"
    fi
fi
setupEnvConfig
su - vagrant -c "nix-env -f '<nixpkgs>' -i cicd-shell -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/${nixpkgs_ref}.tar.gz"
