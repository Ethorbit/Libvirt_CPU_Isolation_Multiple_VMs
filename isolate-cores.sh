#!/bin/bash
IS_VERBOSE="0"

# Create temporary file to manage active core isolations (for all virtual machines)
ISOLATED_CPU_FILE="/tmp/libvirt-isolated-cpus.txt"
touch "$ISOLATED_CPU_FILE"

# Handle args
while [ $# -gt 0 ]; do 
     case $1 in 
	  -l | --list)
	       # add ability to list a specific virtual machine's cores later
	       cat "$ISOLATED_CPU_FILE"
	       exit; 
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
	  -v | --verbose)
	       IS_VERBOSE="1"
	  ;;
     esac
     shift
done

# Add this virtual machine's entry to the file if it doesn't exist:
if ! cat "$ISOLATED_CPU_FILE" | grep -q "^$VIRTUAL_MACHINE_NAME"; then 
     echo "$VIRTUAL_MACHINE_NAME" >> "$ISOLATED_CPU_FILE"
     [ "$IS_VERBOSE" -eq 1 ] && echo "Added new entry for $VIRTUAL_MACHINE_NAME" 
fi

# Sanitize --cores 
range=$(echo "$ISOLATE_THESE_CORES" | grep -o "\b\([0-9]*-[0-9]*\)\b")

if [ $(echo "$range" | wc -c) -gt 1 ]; then # They're adding cores with a range 
     range_min=$(echo "$range" | cut -d "-" -f1)
     range_max=$(echo "$range" | cut -d "-" -f2)  

     [ "$IS_VERBOSE" -eq 1 ] && echo "Processing core range $range_min to $range_max" 

     for ((i = $range_min; i <= $range_max; i++)); do
	  sanitized_core_list="$sanitized_core_list $i"	  
     done
else # They're adding a separated list
     cores=$(echo "$ISOLATE_THESE_CORES" | grep -o "[0-9]*") 

     for i in $cores; do
	  sanitized_core_list="$sanitized_core_list $i"
     done
fi

[ "$IS_VERBOSE" -eq 1 ] && echo "Processed core list: $sanitized_core_list" 
[ -z "$sanitized_core_list" ] && exit; 

if [ "$IS_ADDING" -ge 1 ]; then 			
     sed -i "/^$VIRTUAL_MACHINE_NAME/c $VIRTUAL_MACHINE_NAME $sanitized_core_list" "$ISOLATED_CPU_FILE" 
else
     sed -i "/^$VIRTUAL_MACHINE_NAME/ s/$sanitized_core_list//" "$ISOLATED_CPU_FILE"
fi

if [ "$IS_VERBOSE" -eq 1 ]; then 
     if [ "$IS_ADDING" -eq 1 ]; then 
	  echo "Adding isolated cores for $VIRTUAL_MACHINE_NAME"
     else 
	  echo "Removing isolated cores from $VIRTUAL_MACHINE_NAME"
     fi
fi

# Finally, read from the file containing all isolated cores, relay it to Systemd
all_isolated_cores=$(cat "$ISOLATED_CPU_FILE")
allowed_cores=""

for ((i = 0; i <= $(nproc --all) - 1; i++)); do 
     echo "Testing $i"
     if ! echo "$all_isolated_cores" | grep -q "\s$i\b"; then 
	  allowed_cores="$allowed_cores$i,"
     fi 
done

[ -z "$allowed_cores" ] && exit;
allowed_cores="${allowed_cores::-1}"

[ "$IS_VERBOSE" -eq 1 ] && echo "Cores allowed on host: $allowed_cores" 
systemctl set-property --runtime -- system.slice AllowedCPUs=$allowed_cores
systemctl set-property --runtime -- user.slice AllowedCPUs=$allowed_cores
systemctl set-property --runtime -- init.scope AllowedCPUs=$allowed_cores
