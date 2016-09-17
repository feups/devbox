#! /usr/bin/env bash

echo "Configuring user"

cp .xmobarrc "${HOME}/.xmobarrc";
install -Dm644 xmonad.hs "${HOME}/.xmonad/xmonad.hs";

cp .bashrc "${HOME}/.bashrc";
cp .wallpaper.jpg "${HOME}/.wallpaper.jpg";
install -Dm644 terminalrc "${HOME}/.config/xfce4/terminal/terminalrc";

install -Dm644 config.nix "${HOME}/.nixpkgs/config.nix";
cp -r pkgs "${HOME}/.nixpkgs/"

rsync --remove-source-files --chmod=ugo-x /tmp/ssh-keys/*.pub /home/vagrant/.ssh/
rsync --remove-source-files --chmod=go-rw /tmp/ssh-keys/+([^.]) /home/vagrant/.ssh/
