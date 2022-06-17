#!/bin/bash
ISOLATE_THESE_CORES="$1"
IS_ADDING="$2"
ISOLATED_CPU_FILE="/tmp/libvirt-isolated-cpus.txt"

# Create temporary file to manage active core isolations (for all virtual machines)
touch "$ISOLATED_CPU_FILE"

if [ -s "$ISOLATED_CPU_FILE" ]; then 
	sanitized_core_list=","
else
	sanitized_core_list=""
fi

range=$(echo "$ISOLATE_THESE_CORES" | grep -o "\b\([0-9]*-[0-9]*\)\b")

if [ $(echo "$range" | wc -c) -gt 1 ]; then # They're adding cores with a range 
     range_min=$(echo "$range" | cut -d "-" -f1)
     range_max=$(echo "$range" | cut -d "-" -f2)  

     for ((i = $range_min; i <= $range_max; i++))
     {
	  sanitized_core_list="$sanitized_core_list$i,"	  
     }
else # They're adding cores with a comma separated list
	cores=$(echo "$ISOLATE_THESE_CORES" | grep -o "[0-9]*")
	
	for i in $cores; do
		sanitized_core_list="$sanitized_core_list$i,"
	done
fi

if [ -z "$sanitized_core_list" ]; then 
     exit;
fi 

sanitized_core_list="${sanitized_core_list::-1}"
echo "Comma separated list of what you wanted: $sanitized_core_list"

if [ "$IS_ADDING" -ge "1" ]; then 	
	# Make sure if it's a range that it's converted to a comma separated list
	echo "add to file"		
	#sed -i "1 s/\$/$sanitized_core_list/" "$ISOLATED_CPU_FILE" 
else
	echo "remove from file"
	#sed -i "1 s/$sanitized_core_list//" "$ISOLATED_CPU_FILE"
fi 

isolated_cores=$(cat "$ISOLATED_CPU_FILE")

# Isolate the cores from the variable read above
#systemctl set-property --runtime -- system.slice AllowedCPUs=4,5,6,7
#systemctl set-property --runtime -- user.slice AllowedCPUs=4,5,6,7
#systemctl set-property --runtime -- init.scope AllowedCPUs=4,5,6,7
