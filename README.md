# Dynamic Libvirt CPU Isolation
Scenario: You need to isolate the cores at runtime for several libvirt virtual machines that may use different cores, but you don't want to conflict with existing isolated cores and you want the cores made available to the host again as soon as the VMs using them have powered off.

## 1. Add isolate-cores.sh
`wget "https://raw.githubusercontent.com/Ethorbit/Libvirt_CPU_Isolation_Multiple_VMs/main/isolate-cores.sh" -O /usr/bin/isolate-cores.sh && chmod +x /usr/bin/isolate-cores.sh`

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
isolate-cores.sh --name "$GUEST_NAME" --cores "0,1,2,3" --add
```

Inside the release script, add:
```
GUEST_NAME="$1"
isolate-cores.sh --name "$GUEST_NAME" --cores "0,1,2,3" --remove
```
Change the values to the cores you want to isolate from the host. 

**Tip:** You can also do a range (e.g., "0-3") instead.

## 4. Restart libvirt
`systemctl restart libvirtd`

## 5. Test it 
Start the VM and see if the entry was added.

`isolate-cores.sh --list`

You should see something like this when it's on:
> My-VM-Name 0 1 2 3

And when turned off:
> My-VM-Name
