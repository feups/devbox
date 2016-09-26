# DEVBOX


## Usage

```
vagrant box add devbox-1609 packer_vbox-nixos_1609.box
vagrant up
```

### Windows manager

The devbox comes with a [tiling windows manager](https://en.wikipedia.org/wiki/Tiling_window_manager) called [xmonad](http://xmonad.org/). Such a minimal approach has been chosen for 3 reasons:

* Efficiency: the box needs to consume as minimum CPU/Mem resources as possible
* Simplicity: the window manager is basic but yet quite flexible
* Practicality: the desktop is distraction free.

#### Minimal cheat sheet

| Command | Description |
| --------- | ------|
| `<Super> p` | Open Menu |
| `<Super> <Shift> Enter` | New terminal |
| `<Super> Tab` | Change between horizontal, vertical and stack layout |
| `<Super> <Shift> c` | Close (kill) current window |
| `<Super> m`, `<Super> h` | Resize windows |


PS: another good candidate as a tiling manager would be [i3](https://i3wm.org/). If you like it better, please contact the CICD team for a vote in that direction.

## Provision

The provisioning is done automatically the first time `vagrant up` is executed. You can provision again later on by using `vagrant provision`. This is useful to check for a configuration update.

Provisioning is separated into two steps: `system` to configure the system and `user` to configure the vagrant user. You can selectively ask for provisioning using:

```
vagrant provision --provision-with system
vagrant provision --provision-with user
vagrant provision --provision-with ssh-keys
```

## Customization

You can add some specific configuration by editing `/etc/nixos/local-configuration.nix`. This file is never overridden by a call for provisioning. For instance if you want to install the `geany` package, just uncomment the adhoc line.

## Import your ssh private/public keys

Before provisioning, create a directory `ssh-keys` on the host (where the `Vagrantfile` sits) and place all your keys in it.

Please note that:

* public keys should have the extension `.pub` while private keys have no extension.
* your Bitbucket key pair should be named `cirb_rsa` and `cirb_rsa.pub` respectively.

These keys will be automatically placed in the `.ssh` folder of the vagrant user on the guest OS with the correct file permissions.
