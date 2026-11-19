# Home Network Lab - Device Management

Management network: **VLAN 30 - `10.0.30.0/24`**

## Access Layer

| Device Name | Management IP |
|---|---|
| `access-1` | `10.0.30.11` |
| `access-2` | `10.0.30.12` |

## Distribution Layer

| Device Name | Management IP |
|---|---|
| `dist-1` | `10.0.30.2` |
| `dist-2` | `10.0.30.3` |

## Core Layer

| Device Name | Management IP |
|---|---|
| `core-1` | `10.0.30.101` |
| `core-2` | `10.0.30.102` |

## Edge Transit Layer

| Device Name | Management IP |
|---|---|
| `TR_L3_1` | `10.0.30.111` |
| `TR_L3_2` | `10.0.30.112` |

## Firewalls

| Device Name | Management IP |
|---|---|
| `ASAv` | `10.0.30.201` |
| `FortiGate` | `10.0.30.202` |

## Management Layer

| Device Name | Management IP |
|---|---|
| `MGMT-1` | `10.0.30.21` |
| `MGMT-2` | `10.0.30.22` |

---

## Management Design

VLAN 30 (`10.0.30.0/24`) is dedicated to out-of-band device management.

Infrastructure-generated production and lab traffic should use the appropriate in-band network instead of VLAN 30.

