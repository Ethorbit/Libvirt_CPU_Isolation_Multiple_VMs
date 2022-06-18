#!/bin/bash
# Create temporary file to manage active core isolations (for all virtual machines)
ISOLATED_CPU_FILE="/tmp/libvirt-isolated-cpus.txt"
touch "$ISOLATED_CPU_FILE"

# Handle args
while [ $# -gt 0 ]; do 
     case $1 in 
	  -l | --list)
	       exit; # Implement soon, I guess
	  ;;
	  -n | --name)
	       VIRTUAL_MACHINE_NAME="$2"
	  ;;
	  -c | --cores)
	       ISOLATE_THESE_CORES="$2"
	  ;;
	  -a | --add)
	       IS_ADDING="1"
	  ;;
	  -r | --remove)
	       IS_ADDING="0"
	  ;;
     esac
     shift
done

# Add this virtual machine's entry to the file if it doesn't exist:
if ! cat "$ISOLATED_CPU_FILE" | grep "^$VIRTUAL_MACHINE_NAME"; then 
     echo "$VIRTUAL_MACHINE_NAME" >> "$ISOLATED_CPU_FILE"
fi

# Process and sanitize --cores 
range=$(echo "$ISOLATE_THESE_CORES" | grep -o "\b\([0-9]*-[0-9]*\)\b")

if [ $(echo "$range" | wc -c) -gt 1 ]; then # They're adding cores with a range 
     range_min=$(echo "$range" | cut -d "-" -f1)
     range_max=$(echo "$range" | cut -d "-" -f2)  

     for ((i = $range_min; i <= $range_max; i++))
     {
	  sanitized_core_list="$sanitized_core_list $i"	  
     }
else # They're adding a separated list
     cores=$(echo "$ISOLATE_THESE_CORES" | grep -o "[0-9]*")
	
     for i in $cores; do
	  sanitized_core_list="$sanitized_core_list $i"
     done
fi

if [ -z "$sanitized_core_list" ]; then 
     exit;
fi 

if [ "$IS_ADDING" -ge 1 ]; then 			
     sed -i "/^$VIRTUAL_MACHINE_NAME/c $VIRTUAL_MACHINE_NAME $sanitized_core_list" "$ISOLATED_CPU_FILE" 
else
     sed -i "/^$VIRTUAL_MACHINE_NAME/ s/$sanitized_core_list//" "$ISOLATED_CPU_FILE"
fi

# Finally, read from the file containing all isolated cores, communicate it to Systemd
all_isolated_cores=$(cat "$ISOLATED_CPU_FILE")
allowed_cores=""

for i in $(lscpu -e | awk '{print $1}'); do  
     if ! echo "$all_isolated_cores" | grep "\s$i\s"; then 
	  allowed_cores="$allowed_cores$i,"
     fi 
done

if [ -z "$allowed_cores" ]; then 
     exit;
fi

allowed_cores="${allowed_cores::-1}"

echo "Finally we will only allow these cores on the host: $allowed_cores"

# Isolate the cores from the variable read above
#systemctl set-property --runtime -- system.slice AllowedCPUs=4,5,6,7
#systemctl set-property --runtime -- user.slice AllowedCPUs=4,5,6,7
#systemctl set-property --runtime -- init.scope AllowedCPUs=4,5,6,7
