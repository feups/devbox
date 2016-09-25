#! /usr/bin/env bash

cicd_dir="${HOME}/projects/cicd"

echo "Configuring user"

echo "Installing dotfiles"
nix-build dotfiles.nix -o dotfiles
stow dotfiles -v -t "$HOME"

echo "Installing common files"

cp .wallpaper.jpg "${HOME}/.wallpaper.jpg";

install -Dm644 config.nix "${HOME}/.nixpkgs/config.nix";
cp -r pkgs "${HOME}/.nixpkgs/"

cp ssh-config "${HOME}/.ssh/config";
private_keys=$(find /tmp/ssh-keys -maxdepth 1 -type f ! -name "*.*" )
rsync --remove-source-files --chmod=ugo-x /tmp/ssh-keys/*.pub "${HOME}/.ssh/"
rsync --chmod=go-rw  "$private_keys" "${HOME}/.ssh/"

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
