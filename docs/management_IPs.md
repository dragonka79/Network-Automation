# Home Network Lab - Device Management

Management network: **VLAN 30 - `10.0.30.0/24`**

## Access

| Device | Management IP |
|---|---:|---|
| Access-1 | `10.0.30.11` |
| Access-2 | `10.0.30.12` |

## Distribution

| Device | Management IP |
|---|---:|---|
| Dist-1 | `10.0.30.2` |
| Dist-2 | `10.0.30.3` |

## Core

| Device | Management IP |
|---|---:|---|
| Core-1 | `10.0.30.101` |
| Core-2 | `10.0.30.102` |

## Edge Transit

| Device | Management IP |
|---|---:|---|
| TR_L3_1 | `10.0.30.111` |
| TR_L3_2 | `10.0.30.112` |

## Firewalls

| Device | Management IP |
|---|---:|---|
| ASAv | `10.0.30.201` |
| FortiGate | `10.0.30.202` |

## Management

| Device | Management IP |
|---|---:|---|
| MGMT-1 | `10.0.30.21` |
| MGMT-2 | `10.0.30.22` |

---

> VLAN 30 is dedicated to out-of-band device management. Production/lab traffic from infrastructure devices should use the appropriate in-band network instead.

