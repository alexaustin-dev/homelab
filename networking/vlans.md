Network segmentation via VLANs for security, performance, and organization.

## VLAN Configuration

| VLAN Name      | Tag      | Subnet         | Purpose                                    |
| -------------- | -------- | -------------- | ------------------------------------------ |
| **Default**    | Untagged | 10.10.1.0/24   | Home PCs and trusted devices               |
| **Servers**    | 10       | 10.10.10.0/24  | Internal servers (non-public)              |
| **WiFi**       | 20       | 10.10.20.0/24  | Phones, tablets, laptops                   |
| **IoT**        | 30       | 10.10.30.0/24  | Echos, Roku, smart devices                 |
| **Security**   | 40       | 10.10.40.0/24  | Cameras and security devices (NYI)         |
| **DMZ**        | 50       | 10.10.50.0/24  | Public-facing servers (Plex, game servers) |
| **Management** | 100      | 10.10.100.0/24 | Network equipment, hypervisors, iDRAC      |

## VLAN Breakdown

### Default (Untagged) - 10.10.1.0/24

**Devices:** Home PCs, trusted workstations **Gateway:** 10.10.1.1

### Servers (VLAN 10) - 10.10.10.0/24

**Devices:** Internal application servers, private VMs **Gateway:** 10.10.10.1

### WiFi (VLAN 20) - 10.10.20.0/24

**Devices:** Smartphones, tablets, laptops **Gateway:** 10.10.20.1

### IoT (VLAN 30) - 10.10.30.0/24

**Devices:** Amazon Echo, Roku, smart home devices **Gateway:** 10.10.30.1

### Security (VLAN 40) - 10.10.40.0/24

**Status:** Not Yet Implemented **Devices:** IP cameras, NVR systems **Gateway:** 10.10.40.1

### DMZ (VLAN 50) - 10.10.50.0/24

**Devices:** Public-facing servers, Plex, game servers **Gateway:** 10.10.50.1

### Management (VLAN 100) - 10.10.100.0/24

**Devices:** Network switches, access points, Proxmox hosts, iDRAC **Gateway:** 10.10.100.1