# Libvirt CPU Isolation with Multiple VMs
Scenario: You need to isolate the cores at runtime for several virtual machines that use different cores, but you don't want to screw up the isolation for the other VMs that may be running when one turns on/off.

This is a tutorial showing how to do this with the only requirement being that you have systemd.

## 1. Add isolate-cores.sh
`wget "https://raw.githubusercontent.com/Ethorbit/Libvirt_CPU_Isolation_Multiple_VMs/main/isolate-cores.sh" -O /etc/libvirt/hooks/isolate-cores.sh && chmod +x /etc/libvirt/hooks/isolate-cores.sh`

## 2. Create the hook files for your virtual machines
Libvirt executes scripts in directories that have the same name as a VM when it starts, stops, etc

Create these two files:
* `/etc/libvirt/hooks/qemu.d/your vm's name/prepare/begin/start.sh`
* `/etc/libvirt/hooks/qemu.d/your vm's name/release/end/revert.sh`

(Make sure to chmod +x them)

**Tip:** you can create a symbolic link pointing to a single directory instead if many virtual machines need the same hooks (e.g.,
`ln -s /etc/libvirt/hooks/qemu.d/FourCores /etc/libvirt/hooks/qemu.d/your vm's name`)

## 3. Edit the hook files
Inside the prepare script, add:
```
GUEST_NAME="$1"
/etc/libvirt/hooks/isolate-cores.sh --name "$GUEST_NAME" --cores "0,1,2,3" --add
```

Inside the release script, add:
```
GUEST_NAME="$1"
/etc/libvirt/hooks/isolate-cores.sh --name "$GUEST_NAME" --cores "0,1,2,3" --remove
```
Change the values to the cores you want to isolate from the host. 

**Tip:** You can also do a range (e.g., "0-3"), but you cannot do both at once.

## 4. Restart libvirt
`systemctl restart libvirtd`
