# Overview

Complete network infrastructure layout

## Network Topology

```
ISP
    ↓ COAX
Arris S33 Modem
    ↓ Ethernet (Port 9 on Dream Machine)
UDM-SE
    ↓ SFP (Port 11 - Trunk, All VLANs)
USW-24-PoE (SW-001)
    ├─ Port 2  → WAP-001 (U6-LR)
    ├─ Port 24 → SW-002 (USW-Lite-8)
    └─ Port 26 → UDM-SE (Uplink)
```

## Connection Details

### ISP Connection

| Component           | Details                     |
| ------------------- | --------------------------- |
| **ISP**             | Cable Connections           |
| **Connection Type** | COAX                        |
| **Modem**           | Modem - Arris Surfboard S33 |

### Modem to Firewall

| Source    | Destination   | Cable Type |
| --------- | ------------- | ---------- |
| Arris S33 | UDM-SE Port 9 | Ethernet   |

### Core Switch Uplink

| Source         | Destination    | Cable Type | Configuration     |
| -------------- | -------------- | ---------- | ----------------- |
| UDM-SE Port 11 | SW-001 Port 26 | SFP        | Trunk (All VLANs) |

### Switch Downlink

| Source         | Destination   | Cable Type |
| -------------- | ------------- | ---------- |
| SW-001 Port 24 | SW-002 Port 8 | Ethernet   |

### Wireless Access Point

| Source  | Destination   | Cable Type     |
| ------- | ------------- | -------------- |
| WAP-001 | SW-001 Port 2 | Ethernet (PoE) |

## Device Summary

| Device   | Model          | IP Address    | Role              |
| -------- | -------------- | ------------- | ----------------- |
| Modem    | Arris S33      | N/A           | ISP Gateway       |
| Firewall | UDM-SE         | 10.10.1.1     | Router/Controller |
| SW-001   | USW 24 PoE     | 10.10.100.210 | Core Switch       |
| SW-002   | USW Lite 8 PoE | 10.10.100.196 | Access Switch     |
| WAP-001  | U6 LR          | 10.10.100.103 | Wireless AP       |
