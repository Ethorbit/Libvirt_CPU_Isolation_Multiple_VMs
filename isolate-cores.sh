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

range=$(echo "$ISOLATE_THESE_CORES" | grep -o "\b\([0-9]-[0-9]\)\b")

if [ $(echo "$range" | wc -c) -gt 1 ]; then # They're adding cores with a range 
        echo "So you want the range? $range"
        # Create list based on range by exploding hyphen and using the first (min) and second (max) values
        # Make sure min is less than max of course

else # They're adding cores with a comma separated list
        cores=$(echo "$ISOLATE_THESE_CORES" | grep -o "[0-9]*")
        
        for i in $cores; do
                sanitized_core_list="$sanitized_core_list$i,"
        done

        sanitized_core_list="${sanitized_core_list::-1}"
fi

echo "Comma separated list of what you wanted: $sanitized_core_list"

if [ "$IS_ADDING" -ge "1" ]; then       
        # Make sure if it's a range that it's converted to a comma separated list
        echo "add to file"              
        #sed -i "1 s/\$/$ISOLATE_THESE_CORES/" "$ISOLATED_CPU_FILE" 
else
        echo "remove from file"
        #sed -i "1 s/$ISOLATE_THESE_CORES//" "$ISOLATED_CPU_FILE"
fi 

isolated_cores=$(cat "$ISOLATED_CPU_FILE")

# Isolate the cores from the variable read above
#systemctl set-property --runtime -- system.slice AllowedCPUs=4,5,6,7
#systemctl set-property --runtime -- user.slice AllowedCPUs=4,5,6,7
#systemctl set-property --runtime -- init.scope AllowedCPUs=4,5,6,7
