
# Stop all VMs one by one listed in VMS list
# /root/stop-vms.sh

#!/bin/bash

VMS=(100 101 103 104 105 106)

TIMEOUT=300
INTERVAL=5

for VMID in "${VMS[@]}"; do

    echo "Checking VM $VMID..."

    if ! qm status "$VMID" | grep -q "status: running"; then
        echo "VM $VMID is already stopped. Skipping."
        continue
    fi

    echo "Shutting down VM $VMID..."

    qm shutdown "$VMID" || {
        echo "ERROR: Shutdown request failed for VM $VMID"
        exit 1
    }

    ELAPSED=0

    while qm status "$VMID" | grep -q "status: running"; do

        if (( ELAPSED >= TIMEOUT )); then
            echo "ERROR: VM $VMID did not shut down within $TIMEOUT seconds."
            exit 1
        fi

        sleep "$INTERVAL"
        ((ELAPSED+=INTERVAL))

    done

    echo "VM $VMID successfully stopped."

done

echo "All VMs have been shut down."

