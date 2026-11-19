# Home Network Lab - Device Management

Management network: **VLAN 30 - `10.0.30.0/24`**

## Access

| Device | Management IP | SSH |
|---|---:|---|
| Access-1 | `10.0.30.11` | `ssh access-1` |
| Access-2 | `10.0.30.12` | `ssh access-2` |

## Distribution

| Device | Management IP | SSH |
|---|---:|---|
| Dist-1 | `10.0.30.2` | `ssh dist-1` |
| Dist-2 | `10.0.30.3` | `ssh dist-2` |

## Core

| Device | Management IP | SSH |
|---|---:|---|
| Core-1 | `10.0.30.101` | `ssh core-1` |
| Core-2 | `10.0.30.102` | `ssh core-2` |

## Edge Transit

| Device | Management IP | SSH |
|---|---:|---|
| TR_L3_1 | `10.0.30.111` | `ssh transit-1` |
| TR_L3_2 | `10.0.30.112` | `ssh transit-2` |

## Firewalls

| Device | Management IP | SSH |
|---|---:|---|
| ASAv | `10.0.30.201` | `ssh asav` |
| FortiGate | `10.0.30.202` | `ssh fgt` |

## Management

| Device | Management IP | SSH |
|---|---:|---|
| MGMT-1 | `10.0.30.21` | `ssh mgmt-1` |
| MGMT-2 | `10.0.30.22` | `ssh mgmt-2` |

---

> VLAN 30 is dedicated to out-of-band device management. Production/lab traffic from infrastructure devices should use the appropriate in-band network instead.

