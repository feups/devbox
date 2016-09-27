# DEVBOX


## Software requirements

- Virtualbox 5.1.x (5.0 should also work)
- Vagrant 1.8.x


## Quick start

### ssh keys

In the host, pick a folder of your choice (where the `Vagrantfile` will sit). In this folder:

1. create a directory `ssh-keys`.
2. copy your `Bitbucket` key pair, rename them 'cirb_rsa' and 'cirb_rsa.pub' respectively if the filename differs.

### box import

```
vagrant box add devbox http://repo.irisnet.be/boxes/devbox.box
vagrant init devbox && vagrant up
```

## Usage

### vagrant

```
# shutdown the vm
vagrant halt
# boot the vm
vagrant up
# update configuration
vagrant provision
```

The provisioning is done automatically the first time `vagrant up` is executed. You can provision again later on by using `vagrant provision`. This is useful to check for a configuration update.

Provisioning is separated into three steps: `system` to configure the system, `user` to configure the vagrant user and `ssh-keys` to push ssl keys. You can selectively ask for provisioning using:

```
vagrant provision --provision-with system
vagrant provision --provision-with user
vagrant provision --provision-with ssh-keys
```

### operating system

The devbox is based on [NixOS](https://nixos.org/) version 16.09. NixOS is a Linux distribution based on the [nix](https://nixos.org/nix/) package manager. The whole system setup is declared in https://github.com/CIRB/devbox/blob/master/system/configuration.nix.

To clean-up the store (whenever the disk usage is too high) use:

```
sudo nix-collect-garbage -d
```

### windows manager

The devbox comes with a [tiling windows manager](https://en.wikipedia.org/wiki/Tiling_window_manager) called [xmonad](http://xmonad.org/). Such a minimal approach has been chosen for 3 reasons:

* Efficiency: the box needs to consume as minimum CPU/Mem resources as possible
* Simplicity: the window manager is basic but yet quite flexible
* Practicality: the desktop is distraction free.

#### minimal cheat sheet

| Command | Description |
| --------- | ------|
| `<Super> p` | Open Menu |
| `<Super> <Shift> Enter` | New terminal |
| `<Super> Tab` | Change between horizontal, vertical and stack layout |
| `<Super> <Shift> c` | Close (kill) current window |
| `<Super> m`, `<Super> h` | Resize windows |


PS: another good candidate as a tiling manager would be [i3](https://i3wm.org/). If you like it better, please contact the CICD team for a vote in that direction.

### projects

The first time, the machine is provisioned a folder `~/projects/cicd` is created. This directory currently contains:

- `puppet` with all the puppet-stack-$hostgroup projects


## Customization

### system

You can add some specific configuration by editing `/etc/nixos/local-configuration.nix`. This file is never overridden by a call for provisioning. For instance if you want to install the `geany` package, just uncomment the adhoc line.

### user

You can add any `dotfiles` repositories including your own personal ones thanks to [vcsh/myrepos](https://github.com/RichiH/vcsh). For instance you might easily add/share some `vim`, `tmux` or `zsh` configurations.

[Look here](https://github.com/RichiH/vcsh/blob/master/doc/README.md#from-zero-to-vcsh) for more information and have a look at the [mr CIRB template](https://github.com/CIRB/vcsh_mr_template).
