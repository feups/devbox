# DEVBOX


## Usage

```
vagrant box add devbox-1609 packer_vbox-nixos_1609.box
vagrant up
```

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
