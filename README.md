# DEVBOX


## Usage

```
vagrant box add devbox-1609 packer_vbox-nixos_1609.box
vagrant up

```
## Import your ssh private/public keys

Before provisioning, create a directory `ssh-keys` on the host (where the `Vagrantfile` sits) and place all your keys in it. Public keys should have the extension `.pub`. For instance:

```
ssh-keys/cirb_rsa
ssh-keys/cirb_rsa.pub
```
These keys will be automatically placed in the `.ssh` folder of the vagrant user on the guest OS with the correct file permissions.
