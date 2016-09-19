#! /usr/bin/env bash

$cicd_dir="${HOME}/projects/cicd"

echo "Configuring user"

cp .xmobarrc "${HOME}/.xmobarrc";
install -Dm644 xmonad.hs "${HOME}/.xmonad/xmonad.hs";

cp .bashrc "${HOME}/.bashrc";
cp .wallpaper.jpg "${HOME}/.wallpaper.jpg";
install -Dm644 terminalrc "${HOME}/.config/xfce4/terminal/terminalrc";

install -Dm644 config.nix "${HOME}/.nixpkgs/config.nix";
cp -r pkgs "${HOME}/.nixpkgs/"

private_keys=$(find /tmp/ssh-keys -maxdepth 1 -type f ! -name "*.*" )
rsync --remove-source-files --chmod=ugo-x /tmp/ssh-keys/*.pub "${HOME}/.ssh/"
rsync --chmod=go-rw  "$private_keys" "${HOME}/.ssh/"


if ! [[ -d "$cicd" ]]; then
  ping -c1 stash.cirb.lan > /dev/null
  if [[ $? -ne 0 ]]; then
      echo "Cannot create cicd projects. No Bitbucket connexion."
      break;
  fi
  echo "Create cicd projects"
  mkdir -p $cicd_dir
  pushd $cicd_dir > /dev/null
  git clone ssh://git@stash.cirb.lan:7999/cicd/puppet-stack-management.git puppet
  popd
fi
