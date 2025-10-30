## Overview

File server with the main objective of being a place to collect and run automation scripts for collecting host information

## Host Information

- **Physical Host:** Host - oreki-pve-002
- **OS:** Operating system and version

## Network Configuration

- **Internal IP:** 10.10.10.11

## Running Services

### oreki-fs-001 - FileBrowser

- **Link:** https://fs001.lab.oreki.io/

### Primary Functions:

1. **NFS Share Server**
   - **Exports:** `/srv/homelab-inventory` via NFS
   - **Allowed networks:** All private subnets (10.0.0.0/8)
   - **Purpose:** Distributes automation scripts and inventory data to other VMs
2. **Web-Based File Management**
   - **FileBrowser** running on port 8888
   - Provides browser-based access to files
3. **Automation Script Repository**
   - Houses critical scripts:
     - `bootstrap.sh` - Initializes new hosts
     - `homelab-inventory` - Infrastructure documentation/inventory generation script
   - Central repository for homelab automation


A lot of what this server does is not very practical, more so experimenting. 