# Network Infrastructure

Complete documentation of the homelab network infrastructure, including physical hardware, VLANs, routing, and security. Shoutout to Claude

---

## 📊 Quick Overview

**Network Design:** Segmented VLANs with Ubiquiti hardware
**External Access:** Tailscale VPN only (no exposed ports)
**SSL/TLS:** Automated via Traefik + Let's Encrypt (Cloudflare DNS challenge)
**Domain:** `*.lab.oreki.io`

---

## 🖧 Physical Network Topology

```
                    Internet (ISP)
                          │
                    ┌─────▼─────┐
                    │   Modem   │
                    └─────┬─────┘
                          │
            ┌─────────────▼──────────────┐
            │  UDM-SE (Router/Firewall)  │
            │      10.10.1.1             │
            └─────────────┬──────────────┘
                          │
            ┌─────────────▼──────────────┐
            │  USW-24-PoE (Core Switch)  │
            │      VLAN Trunking         │
            └──┬────────┬──────────┬─────┘
               │        │          │
          ┌────▼───┐ ┌──▼────┐ ┌──▼─────────┐
          │ U6 LR  │ │USW-8  │ │ Servers    │
          │   AP   │ │Switch │ │ (Proxmox,  │
          │        │ │       │ │  TrueNAS)  │
          └────────┘ └───────┘ └────────────┘
```

---

## 🔧 Hardware Components

### Router/Firewall

**Model:** Ubiquiti Dream Machine SE (UDM-SE)**IP Address:** 10.10.1.1**Functions:**

- Gateway/Router for all VLANs
- Firewall (inter-VLAN rules)
- DHCP server for all networks
- UniFi Network Controller

**Management:** https://dreammachine.lab.oreki.io

**Details:** [hardware.md](hardware.md)

---

### Core Switch

**Model:** Ubiquiti USW 24 PoE**IP Address:** 10.10.100.210 (Management VLAN)**Functions:**

- 24-port managed switch
- PoE+ for access points
- VLAN trunking to all devices

---

### Access Switch

**Model:** Ubiquiti USW Lite 8 PoE**IP Address:** 10.10.100.196 (Management VLAN)**Functions:**

- 8-port managed switch
- Extends network to additional areas
- PoE for secondary devices

---

### Wireless Access Point

**Model:** Ubiquiti U6 LR (WiFi 6)**IP Address:** 10.10.100.103 (Management VLAN)**Functions:**

- WiFi 6 (802.11ax)
- Multiple SSIDs mapped to VLANs
- 2.4GHz and 5GHz bands

---

## 🏷️ VLAN Architecture

Complete VLAN segmentation for security and organization.

**Full Documentation:** [vlans.md](vlans.md)

### Quick Reference

| VLAN           | Tag      | Subnet         | Purpose          | Key Devices              |
| -------------- | -------- | -------------- | ---------------- | ------------------------ |
| **Default**    | Untagged | 10.10.1.0/24   | Trusted devices  | PCs, TrueNAS             |
| **Servers**    | 10       | 10.10.10.0/24  | Internal servers | docker VM, fileserver001 |
| **WiFi**       | 20       | 10.10.20.0/24  | Wireless clients | Phones, tablets, laptops |
| **IoT**        | 30       | 10.10.30.0/24  | Smart home       | Echos, Roku, smart plugs |
| **Security**   | 40       | 10.10.40.0/24  | Cameras (NYI)    | Future IP cameras        |
| **DMZ**        | 50       | 10.10.50.0/24  | Public services  | Future use               |
| **Management** | 100      | 10.10.100.0/24 | Infrastructure   | Switches, Proxmox, iDRAC |

---

## 🌐 Network Services

### DNS

- **Primary:** UDM-SE (10.10.1.1)
- **External:** Cloudflare DNS (1.1.1.1)
- **Internal Resolution:** Handled by Traefik for `*.lab.oreki.io`

### DHCP

- **Server:** UDM-SE
- **Ranges:** Each VLAN has its own DHCP scope
- **Reservations:** Static IPs for all servers and infrastructure

### Routing

- **Inter-VLAN Routing:** UDM-SE
- **Firewall Rules:**
  - IoT → No access to Management/Servers
  - WiFi → Limited access to Servers
  - All → Internet allowed

---

## 🔒 Security & Access

### External Access

**Method:** Tailscale VPN mesh network
**Ports Exposed:** NONE (all access via Tailscale)
**Why:** Zero-trust network access without port forwarding

### Internal Access

**Method:** Traefik reverse proxy
**SSL Certificates:** Let's Encrypt (wildcard `*.lab.oreki.io`)

### Firewall Strategy

1. **Default deny** between VLANs
2. **IoT isolated** from trusted networks
3. **Management VLAN** restricted to admin devices only
4. **Servers VLAN** accessible from trusted networks only

---

## 📈 Network Performance

### Bandwidth

- **ISP Connection:** 1000 Mbps Down / 50 Mbps Up
- **Internal Switching:** 1 Gbps (Cat6)
- **Server Uplinks:** 1-10 Gbps

## 🛠️ Common Tasks

### Adding a New Device

1. Assign to appropriate VLAN based on device type
2. Configure DHCP reservation (if needed)
3. Update firewall rules if special access required
4. Document in appropriate location

### Creating a New Service

1. Deploy service on appropriate VLAN
2. Add Traefik route in `config.yml` or docker labels
3. Configure DNS in Cloudflare (if needed)
4. Test via Tailscale

---

## 📚 Related Documentation

- [Hardware Details](hardware.md) - Network equipment specifications
- [VLAN Configuration](vlans.md) - Complete VLAN breakdown
- [Traefik Setup](../services/docker/infrastructure/traefik/) - Reverse proxy config
- [Security Policies](../docs/security.md) - Firewall rules and access control

---

## 🎯 Future Improvements

- [ ] Implement 10G networking, need proper switching/cables.
- [ ] Add network diagram with current device placement

---

**Last Updated:** October 29, 2025
