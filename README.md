# Homelab Infrastructure

Documenting my homelab environment as I go. Learning more everyday.

## Overview

This repository documents my homelab infrastructure. I maintain and develop it in my free time and am working on converting internal Obsidian notes into a public facing resource I can share with friends and colleagues.
I utilize Claude in the organizing of notes and ideas, specifically for helping with Markdown formatting and flow.
I also utilize Claude in the creation of some scripts, usually in order to get ideas off the floor that I can then finetune and tweak for my needs.

## 🚀 Quick Links
- [Network Documentation](networking/README.md)
- [Host Specifications](hosts/README.md)
- [Services](services/)

## Network Infrastructure

I run a Ubiquiti stack at home. While it is not my first choice as a networking vendor, the ease of use and price makes it a great choice to run in a home environment.

- **Firewall**
  - Ubiquiti Dream Machine
- **Switches**
  - Ubiquiti USW 24 PoE
  - Ubiquiti USW Lite 8 PoE
- **Wireless Access Points**
  - Ubiquiti U6 LR

## Server Infrastructure

I currently run with 4 physical hosts

#### Proxmox Hosts

- 2x Minisforum MS-A2
  - AMD Ryzen  9 9955HX
  - 64GB DDR5  5600 MHZ
  - 1 TB SSD
- 1x Protectili Vault VP4760
  - Intel i7-10810
  - 32 GB DDR4
  - 1TB SSD

#### TrueNAS Host

- 1x Supermicro SuperStorage 6028R-E1CR16T
  - 2x Xeon E5-2640
  - 128GB DDR4
  - 96TB SAS HDD
    The 3 Proxmox hosts are in a cluster but not currently setup for any HA or CEPH storage.
    The TrueNAS Host storage is  broken down into three ZFS pools, two of about 30~TB usable and one pool dedicated for storage for apps running off the host.

## Network Overview

#### VLAN Configuration


| VLAN Name      | Tag      | Subnet         | Purpose                                    |
| ---------------- | ---------- | ---------------- | -------------------------------------------- |
| **Default**    | Untagged | 10.10.1.0/24   | Home PCs and trusted devices               |
| **Servers**    | 10       | 10.10.10.0/24  | Internal servers                           |
| **WiFi**       | 20       | 10.10.20.0/24  | Phones, tablets, laptops                   |
| **IoT**        | 30       | 10.10.30.0/24  | Echos, Roku, smart devices                 |
| **Security**   | 40       | 10.10.40.0/24  | Cameras and security devices               |
| **DMZ**        | 50       | 10.10.50.0/24  | Public-facing servers (Plex, game servers) |
| **Management** | 100      | 10.10.100.0/24 | Network equipment, hypervisors, iDRAC      |

While I typically would avoid setting up devices on native VLAN, at home it started from there and grew.

#### Traefik

I am using Traefik as a reverse proxy in order to assign domain names and SSL certificates to internal services

#### TailScale

Everything in my lab is a part of my Tailnet. I don't expose anything to the external internet (yet) but still have the ability to access my internal services and tools from anywhere.

## Current Projects - 10/28/2025

- [ ] Implement Proxmox HA clustering with Ceph storage
- [ ] Deploy Grafana + Prometheus for metrics collection
- [ ] Create automated backup system for VMs and containers
- [ ] Document network topology with interactive diagrams
- [ ] Setup Kubernetes on one of my hosts

## Contributing

This is a personal learning project, but I welcome:

- Questions and discussions (open an issue!)
- Suggestions for improvements
- Feedback on my approach

Feel free to fork this repo and adapt it for your own homelab documentation!

---

## 🔒 Security Note

This repository contains documentation and configuration files for my homelab infrastructure.

**Important security considerations:**

- All services are accessible **only via Tailscale** - no ports exposed to public internet
- Internal IPs (10.10.x.x) and domain names (*.lab.oreki.io) are published for educational purposes
- All credentials and secrets use environment variables

If you find sensitive information accidentally committed, please open an issue immediately.

```

## License

MIT License - Use anything here for your own projects!

---

**Last Updated:** October 28, 2025
**Status:** Active development and documentation ongoing
```
