# Overview

Host for miscellaneous VMs.TB

## Hardware Specifications

- **CPU:** AMD Ryzen 9 9955HX
- **RAM:** 64GB DDR5 5600MHZ
- **Storage:** 1TB SSD
- **Management:** Proxmox Web UI

## Network Configuration

- **Primary IP:** 10.10.100.13
- **Hostname:** oreki-pve-002
- **Web UI:** https://pve001.lab.oreki.io/

## Hosted Virtual Machines

### oreki-fs-001

- **Purpose:** Ubuntu Server running FileBrowser for WebUI file access
- **Resources:** (2 CPU, 2 GB RAM, 240 GB disk)
- **IP:** 10.10.10.11
- **Services:** Docker, File Browser
