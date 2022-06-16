Tutorial to isolate the cores of 2+ virtual machines which have different cores without conflicting.

# Create the hook files
Libvirt runs scripts in directories that have the same name as a Virtual Machine located in /etc/libvirt/hooks/qemu.d 

These two scripts are the only relevant ones you need to make:
* `/etc/libvirt/hooks/qemu.d/vm name/prepare/begin/start.sh`
* `/etc/libvirt/hooks/qemu.d/vm name/release/end/revert.sh`

**Tip:** you can create a symbolic link pointing to a single directory if many virtual machines need to isolate the same cores:
`ln -s /etc/libvirt/hooks/qemu.d/FourCores /etc/libvirt/hooks/qemu.d/vm name`

Inside the prepare script, add:
```
xd
```

Inside the release script, add:
```
xd
```
