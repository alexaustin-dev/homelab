## Overview
First host when I started the lab, originally a PFSense firewall. Eventually became my 2nd proxmox node. 

## Hardware Specifications
- **CPU:** i7-10810
- **RAM:** 2x 16GB DDR4
- **Storage:** 1TB SSD
- **Management:** Proxmox Web UI

## Network Configuration
- **Primary IP:** 10.10.100.11
- **Hostname:** proxmox2
- **Web UI:** https://proxmox2.lab.oreki.io/

## Hosted Virtual Machines


### [[VM - oreki-docker-001]] (VM ID 100)
- **Purpose:** Ubuntu Server running Docker
- **Resources:** (10 CPU, 24 GB RAM, 240 GB disk)
- **IP:** 10.10.10.10
- **Services:** Docker, Plex, Traefik, Homarr, Portainer
- **Link:** [[VM - oreki-docker-001]]