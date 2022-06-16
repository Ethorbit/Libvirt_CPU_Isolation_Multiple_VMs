# Libvirt CPU Isolation with Multiple VMs
Scenario: You need to isolate the cores for several virtual machines that have different core configurations, but you don't want to screw up the isolation for the other VMs that may be running.

This is a tutorial showing how to do exactly that.

## Create the hook files for your virtual machines
Libvirt runs scripts in directories that have the same name as a VM when it starts, stops, etc

Create these two files:
* `/etc/libvirt/hooks/qemu.d/your vm's name/prepare/begin/start.sh`
* `/etc/libvirt/hooks/qemu.d/your vm's name/release/end/revert.sh`

**Tip:** you can create a symbolic link pointing to a single directory if many virtual machines need the same hooks:
`ln -s /etc/libvirt/hooks/qemu.d/FourCores /etc/libvirt/hooks/qemu.d/your vm's name`

## Editing the hook files
Inside the prepare script, add:
```
xd
```

Inside the release script, add:
```
xd
```
