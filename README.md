# DEVBOX


## Software requirements

- Virtualbox 5.1.x (5.0 should also work)
- Vagrant 1.8.x


## Quick first time setup

### ssh keys

In the host, pick a folder of your choice (where the `Vagrantfile` will sit). In this folder:

1. create a directory `ssh-keys`.
2. copy your `Bitbucket` key pair, rename them 'cirb_rsa' and 'cirb_rsa.pub' respectively if the filename differs.
3. copy your `Github` key pair, rename them 'cirb_github_rsa' and 'cirb_github_rsa.pub'. If you use the same key pair, copy the previous pair and rename accordingly.

### box import

Open a terminal in the picked folder and type:

```
vagrant box add devbox http://repo.irisnet.be/boxes/devbox.box
vagrant init devbox && vagrant up
vagrant reload
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

Provisioning is separated into two steps: `system` to configure the system and `user` to configure the vagrant user. You can selectively ask for provisioning using:

```
vagrant provision --provision-with system
vagrant provision --provision-with user
```

### operating system

The devbox is based on [NixOS](https://nixos.org/) version 16.09. NixOS is a Linux distribution based on the [nix](https://nixos.org/nix/) package manager. The whole system setup is declared in https://github.com/CIRB/devbox/blob/master/system/configuration.nix.

To clean-up the store (whenever the disk usage is too high) use:

```
→ sudo nix-collect-garbage -d
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
| `<Super> t` | New terminal |
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

After changing the `local-configuration.nix` file, rebuild `nixos` by using this command line:

```
→ sudo nixos-rebuild switch
```

### user

### dotfiles

You can add any `dotfiles` repositories including your own personal ones thanks to [vcsh/myrepos](https://github.com/RichiH/vcsh). For instance you might easily add/share some `vim`, `tmux` or `zsh` configurations.

[Look here](https://github.com/RichiH/vcsh/blob/master/doc/README.md#from-zero-to-vcsh) for more information and have a look at the [mr CIRB template](https://github.com/CIRB/vcsh_mr_template).

### local packages

If you need a package in 'user space' (and you are not interested in sharing such configuration), you might prefer the more imperative approach:

```
→ nix-env -i geany
```

## How is the box generated ?

The box is generated using packer and the source files from [here](https://github.com/zimbatm/nixbox):

```
packer.exe build nixos-x86_64.json
vagrant box add devbox-x.x-pre packer_virtualbox-iso_virtualbox.box
```
The size of the 'pre box' is ~ 300M

The box is then repackaged to a full vm:

```
git clone git@github.com:CIRB/devbox.git
cd devbox
vagrant up --no-provision
vagrant provision --provision-with system
vagrant reload
vagrant package --output devbox-0.x --vagrantfile Vagrantfile
```

The size of the repackaged vagrant box is about ~2G.


## TODOs

- [ ] Populate ssh config
- [ ] Use `mr` to fetch projects sources
- [ ] Add salt in projects
