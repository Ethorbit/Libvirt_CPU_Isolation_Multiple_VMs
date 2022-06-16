# Libvirt CPU Isolation with Multiple VMs
Scenario: You need to isolate the cores for several virtual machines that have different core configurations, but you don't want to screw up the isolation for the other VMs that may be running.

This is a tutorial showing how to do this.

## 1. Add isolate-cores.sh
`git clone "https://github.com/Ethorbit/Libvirt_CPU_Isolation_Multiple_VMs.git" && cd Libvirt_CPU_Isolation_Multiple_VMs`

`mv ./isolate-cores.sh /etc/libvirt/hooks/isolate-cores.sh`

## 2. Create the hook files for your virtual machines
Libvirt executes scripts in directories that have the same name as a VM when it starts, stops, etc

Create these two files:
* `/etc/libvirt/hooks/qemu.d/your vm's name/prepare/begin/start.sh`
* `/etc/libvirt/hooks/qemu.d/your vm's name/release/end/revert.sh`

**Tip:** you can create a symbolic link pointing to a single directory if many virtual machines need the same hooks e.g:
`ln -s /etc/libvirt/hooks/qemu.d/FourCores /etc/libvirt/hooks/qemu.d/your vm's name`

## 3. Edit the hook files
Inside the prepare script, add:
```
/etc/libvirt/hooks/isolate-cores.sh "0,1,2,3" "1"
```

Inside the release script, add:
```
/etc/libvirt/hooks/isolate-cores.sh "0,1,2,3" "0"
```
change the values to the cores you need to isolate.

## 4. Restart libvirt
`systemctl restart libvirtd`
