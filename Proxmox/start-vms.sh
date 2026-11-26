#!/bin/bash

# Start all VMs one by one listed in VMS list
# /root/start-vms.sh

VMS=(100 101 103 104 105 106)

TIMEOUT=300
INTERVAL=5

for VMID in "${VMS[@]}"; do

    echo "Starting VM $VMID..."

    qm start "$VMID" || {
        echo "ERROR: Could not start VM $VMID"
        exit 1
    }

    echo "Waiting for QEMU Guest Agent on VM $VMID..."

    ELAPSED=0

    until qm guest cmd "$VMID" ping &>/dev/null; do

        if (( ELAPSED >= TIMEOUT )); then
            echo "ERROR: Guest Agent timeout on VM $VMID"
            exit 1
        fi

        sleep "$INTERVAL"
        ((ELAPSED+=INTERVAL))

    done

    echo "VM $VMID is responding."

done

echo "All VMs successfully started."

