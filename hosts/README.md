# Physical Hosts

Documentation for all physical servers in the homelab infrastructure. Shoutout to Claude.

---

## 📊 Fleet Overview


| Hostname          | Model            | CPU                      | RAM        | Storage   | Role           | Status    |
| ------------------- | ------------------ | -------------------------- | ------------ | ----------- | ---------------- | ----------- |
| **oreki-pve-001** | Minisforum MS-A2 | Ryzen 9 9955HX (16C/32T) | 64GB DDR5  | 1TB NVMe  | Proxmox Node   | 🟢 Active |
| **oreki-pve-002** | Minisforum MS-A2 | Ryzen 9 9955HX (16C/32T) | 64GB DDR5  | 1TB NVMe  | Proxmox Node   | 🟢 Active |
| **proxmox2**      | Protectli VP4760 | i7-10810U (6C/12T)       | 32GB DDR4  | 832GB SSD | Proxmox Node   | 🟢 Active |
| **truenas**       | Supermicro 6028R | 2x Xeon E5-2640 v4       | 128GB DDR4 | 96TB HDD  | Storage + Apps | 🟢 Active |

**Total Compute:** 38 cores / 76 threads
**Total RAM:** 288GB
**Total Storage:** ~100TB (usable ~70TB)

---

## 🖥️ Proxmox Cluster

### Cluster Configuration

**Cluster Name:** `oreki-cluster`
**Proxmox Version:** 9.0.11
**Nodes:** 3
**Quorum:** 3-node (HA capable)
**Storage:** Local LVM-Thin per node (no shared storage yet)

**Management URLs:**

- https://proxmox2.lab.oreki.io:8006
- https://pve001.lab.oreki.io:8006
- https://pve002.lab.oreki.io:8006

### Node Details

#### oreki-pve-001 (10.10.100.12) 

**Model:** Minisforum MS-A2
**Documentation:** [oreki-pve-001.md](oreki-pve-001.md)

**Specifications:**

- CPU: AMD Ryzen 9 9955HX (16C/32T, up to 5.4GHz)
- RAM: 65GB DDR5-5600 (upgradable to 96GB)
- Storage: 1TB NVMe SSD (local-lvm)
- Network: Dual 10GbE SFP+ + Dual 2.5GbE RJ45
- Power: ~65W TDP

**Current Workloads:**

- None (ready for deployment)

**Future Plans:**

- Potential Kubernetes setup
- Potential nixos test setup
- GPU passthrough potential (low-profile GPU)

---

#### oreki-pve-002 (10.10.100.13)

**Model:** Minisforum MS-A2
**Documentation:** [oreki-pve-002.md](oreki-pve-002.md)

**Specifications:**

- CPU: AMD Ryzen 9 9955HX (16C/32T, up to 5.4GHz)
- RAM: 65GB DDR5-5600 (upgradable to 96GB)
- Storage: 1TB NVMe SSD (local-lvm)
- Network: Dual 10GbE SFP+ + Dual 2.5GbE RJ45
- Power: ~65W TDP

**Current Workloads:**

- fileserver001 (VM ID: 103) - Infrastructure automation & inventory

**Future Plans:**

- Additional service VMs

---

#### proxmox2 (10.10.100.11)

**Model:** Protectli Vault VP4760
**Documentation:** [proxmox2.md](proxmox2.md)

**Specifications:**

- CPU: Intel Core i7-10810U (6C/12T, up to 4.9GHz)
- RAM: 31GB DDR4-2666
- Storage: 832GB SSD (local-lvm)
- Network: 4x Intel i225 2.5GbE
- Power: 15W TDP

**Current Workloads:**

- docker (VM ID: 100) - Primary services (Traefik, Plex, Homarr, etc.)

**Notes:**

- Lowest performance node in cluster
- Reliable for production services
- Lower power consumption than other nodes

---

## 💾 Storage Host

### truenas (10.10.1.15)

**Model:** Supermicro SuperStorage 6028R-E1CR16T
**Documentation:** [truenas/](truenas/)

**Specifications:**

- CPU: 2x Intel Xeon E5-2640 v4 (10C/20T each, 40 threads total)
- RAM: 128GB DDR4 ECC
- Storage: 96TB raw (3x ZFS pools)
- Network: 2x 10GbE SFP+ + 2x 1GbE
- HBA: LSI 9300-8i (IT mode)
- Power: ~200W typical

**Storage Pools:**


| Pool  | Configuration   | Raw Size | Usable | Purpose              |
| ------- | ----------------- | ---------- | -------- | ---------------------- |
| pool1 | RAIDZ2 (8-wide) | ~36TB    | ~5.5TB | Media storage + apps |
| pool2 | RAIDZ2 (7-wide) | ~36TB    | ~5.5TB | Available            |
| pool3 | Single disk     | ~6TB     | ~5.5TB | Testing/scratch      |

**TrueNAS Apps Running:**

- Sonarr, Radarr, Bazarr, Prowlarr (media automation)
- SABnzbd (Usenet downloader)
- Overseerr (media requests)
- Recyclarr, FlareSolverr (supporting services)

**NFS Exports:**

- `/mnt/pool1/media/tv` → docker VM (Plex)
- `/mnt/pool1/media/movies` → docker VM (Plex)

**Management:** https://truenas.lab.oreki.io

---

## 🔌 Power & Environment

### Power Consumption (Estimates, not actually tested)


| Host          | Idle      | Typical   | Max       | Notes                  |
| --------------- | ----------- | ----------- | ----------- | ------------------------ |
| oreki-pve-001 | ~25W      | ~45W      | ~65W      | Efficient AMD platform |
| oreki-pve-002 | ~25W      | ~45W      | ~65W      | Efficient AMD platform |
| proxmox2      | ~8W       | ~12W      | ~15W      | Very low power         |
| truenas       | ~150W     | ~200W     | ~300W     | 16x HDDs spinning      |
| **Total**     | **~208W** | **~302W** | **~445W** | Plus networking gear   |

### Cooling & Noise

- **Proxmox Nodes:** Nearly silent (small fans)
- **TrueNAS:** Moderate noise (multiple HDD platters, server fans)

---

## 🌡️ Monitoring

### Health Checks

- **Proxmox:** Built-in monitoring (CPU, RAM, storage)
- **TrueNAS:** Built-in SMART monitoring, ZFS health
- **Uptime Kuma:** Service availability monitoring

### Alerts

- [ ] TODO: Setup email/push alerts for:
  - High CPU/RAM usage
  - Disk failures
  - Temperature warnings
  - Service outages

---

## 🔄 Backup Strategy

### Current Status

⚠️ **No automated backup system configured yet (I am sorry)**

### Planned Approach

- [ ] Proxmox VM backups to TrueNAS (PBS or vzdump)
- [ ] TrueNAS ZFS snapshots (automated)
- [ ] Offsite backup for critical data
- [ ] Docker volume backups for service configs

## 🎯 Future Hardware Plans

### Short Term (3-6 months)

- [ ] Add more storage to oreki-pve-001/002 (additional NVMe)

### Long Term (1+ years)

- [ ] Replace proxmox2 with third Minisforum MS-A2
- [ ] Implement Ceph distributed storage across cluster
- [ ] Add low-profile GPU to one node for transcoding/AI

---

## 📚 Related Documentation

- [Virtual Machines](../virtual-machines/README.md) - VMs hosted on these servers
- [Network Infrastructure](../networking/README.md) - Network connectivity
- [Services](../services/docker/) - Services running on VMs
- [TrueNAS Apps](truenas/app-deployment-guide.md) - Native TrueNAS applications

---

## 🔗 Quick Links

**Management Interfaces:**

- [Proxmox Cluster](https://proxmox2.lab.oreki.io:8006)
- [TrueNAS Dashboard](https://truenas.lab.oreki.io)
- [Dream Machine Controller](https://dreammachine.lab.oreki.io)

**Documentation:**

- [oreki-pve-001 Details](oreki-pve-001.md)
- [oreki-pve-002 Details](oreki-pve-002.md)
- [proxmox2 Details](proxmox2.md)
- [TrueNAS Details](truenas/truenas.md)

---

**Last Updated:** October 29, 2025
**Cluster Health:** 🟢 All nodes operational
