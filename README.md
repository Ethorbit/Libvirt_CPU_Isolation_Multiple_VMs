# Libvirt CPU Isolation with Multiple VMs
This is a tutorial showing how to isolate the cores of 2+ virtual machines which have different cores (without conflicting with the isolated cores of the ones possibly running)

## Creating the hook files for your virtual machines
Libvirt runs scripts in directories that have the same name as a VM

Create these two files:
* `/etc/libvirt/hooks/qemu.d/vm name/prepare/begin/start.sh`
* `/etc/libvirt/hooks/qemu.d/vm name/release/end/revert.sh`

**Tip:** you can create a symbolic link pointing to a single directory if many virtual machines need the same hooks:
`ln -s /etc/libvirt/hooks/qemu.d/FourCores /etc/libvirt/hooks/qemu.d/vm name`

## Editing the hook files
Inside the prepare script, add:
```
xd
```

Inside the release script, add:
```
xd
```
