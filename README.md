# DEVBOX


## Software requirements

- Virtualbox 5.1.x
- Vagrant 1.8.x


## Quick first time setup

### ssh keys

In the host, pick a folder of your choice (where the `Vagrantfile` will sit). In this folder:

1. create a directory `ssh-keys`.
2. copy your `Bitbucket` key pair, rename them 'cirb_rsa' and 'cirb_rsa.pub' respectively if the filename differs.
3. copy your `Github` key pair, rename them 'cirb_github_rsa' and 'cirb_github_rsa.pub'. If you use the same key pair, copy the previous pair and rename accordingly.
4. optionally copy the [params file](https://github.com/CIRB/devbox/blob/master/user/params.sh)

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
| `<Super> 1..9` | Go to nth desktop |
| `<Super> <Shift> 1..9` | Switch to nth desktop  |
| `<Super> Space` | Change between horizontal, vertical and stack layout |
| `<Super> Tab`  | In stack layout, switch the stacked window  |
| `<Super> <Shift> c` | Close (kill) current window |
| `<Super> m`, `<Super> h` | Resize windows |
| `F 1`     | Open this README in a browser |


PS: another good candidate as a tiling manager would be [i3](https://i3wm.org/). If you like it better, please contact the CICD team for a vote in that direction.

### projects

The first time, the machine is provisioned a folder `~/projects/cicd` is created. This directory currently contains:

- `puppet` with all the puppet-stack-$hostgroup projects


## Customization

### system

You can add some specific configuration by editing `/etc/nixos/local-configuration.nix`. For instance if you want to install the `geany` package, just uncomment the adhoc line.

After changing the `local-configuration.nix` file, rebuild `nixos` by using this command line:

```
→ sudo nixos-rebuild switch
```

`local-configuration.nix` is never overridden by a call for provisioning. To avoid losing your changes after a `vagrant destroy`, you might want to copy the file to '/vagrant'. In fact if `local-configuration.nix` exists on the host (where the `Vagrantfile` sits), it will be used the first time a box is provisioned.

### user

#### params

You can tweak some default settings such as "do I want to install the geppetto plugin" by modifying the `user/params.sh` file. In order to do so, copy the [file](https://github.com/CIRB/devbox/blob/master/user/params.sh) to the host where the `Vagrantfile` sits. You can easily do this by using this command line on the box:

```
→ cp /tmp/user/devbox-x.x.x/user/params.sh /vagrant/params.sh
````

#### dotfiles

You can add any `dotfiles` repositories including your own personal ones thanks to [vcsh/myrepos](https://github.com/RichiH/vcsh). For instance you might easily add/share some `vim`, `tmux` or `zsh` configurations.

To share simple dotfiles configuration, for instance let say you want to share a default `.zshrc` file for the devbox, you can simply add the file to the [CIRB dotfiles repositry](https://github.com/CIRB/devbox-dotfiles). The file is now part of the default CIRB dotfiles source repository and will be pushed on the devbox at the next provisioning.

If you want to share a non trivial, external or optional configuration, you can use or create a specific source repository for it and register the repository [here](https://github.com/CIRB/vcsh_mr_template/tree/master/.config/mr/available.d). If you want the configuration to be active by default, you then add a link to it in the SCM, just like [this one](https://github.com/CIRB/vcsh_mr_template/blob/master/.config/mr/config.d/dotfiles.vcsh). On the other hand, if you want it to be inactive by default ([spacemacs](https://github.com/CIRB/vcsh_mr_template/blob/master/.config/mr/available.d/spacemacs.mr) is one example), you would ask the interested users to make the link themselves on their box.

Eventually there is a third option. Some of your configurations are personal and there is no need for them to be shared inside the CIRB organization. You normally won't need that option but it is there for flexibility sake. 3 steps are required:

1. Fork [mr CIRB template](https://github.com/CIRB/vcsh_mr_template)
2. Change the [mr pointer](https://github.com/CIRB/vcsh_mr_template/blob/master/.config/mr/available.d/mr.vcsh#L2) to it.
3. Change the `mr` pointer on your local box. As an example, you might follow this command line:

```
→ vcsh mr remote set-url origin git://github.com/PierreR/vcsh_mr_template.git
```
As a note, if you want to override the CIRB dotfiles completely you can replace [the pointer to the dotfiles](https://github.com/PierreR/vcsh_mr_template/commit/82708255d904beffe53b9587e8f553aa8804cc37). In order to keep such a setting after a `vagrant destroy`, you would copy the `user/params.sh` to `/vagrant` and change the `mr_template_repo_url` value.

For more information about `vcsh`, [Look here](https://github.com/RichiH/vcsh/blob/master/doc/README.md#from-zero-to-vcsh).

#### local packages

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
rm -rf /tmp/system # on the future packaged box
vagrant package --output devbox-x.x.x --vagrantfile Vagrantfile
```

The size of the repackaged vagrant box is ~ 2G.


## Devbox lifecycle

The versioning scheme used is semantic: major.minor.patch.

The devbox will be maintained continously with at least a major release every six months to follow the OS lifecycle (*.03 and *.09).


## Troubleshooting

- With virtualbox `5.0.x`, for some host OS, Vagrant does not start its network interface. You will need to manually go "Machine -> Configuration -> Network" and ensure the box "Cable Connected" is checked.


## TODOs

- [ ] Add salt in projects
- [ ] Use `mr` to fetch projects sources
- [ ] Populate ssh config
