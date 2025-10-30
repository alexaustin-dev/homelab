## Overview

Main storage server running TrueNAS SCALE Community Edition. Hosts all media management services (arr stack) as native TrueNAS applications for optimal performance.

**OS Version:** 25.04.2.5

---

## Hardware Specifications

- **CPU:** 2x Intel(R) Xeon(R) CPU E5-2640 v4 @ 2.40GHz
- **RAM:** 128GB DDR4
- **Storage:**
  - **pool1** - RAIDZ2 | 8 wide | 30~ TiB
  - **pool2** - RAIDZ2 | 7 wide | 30~ TiB
  - **pool3** - Single disk | 1 wide | 5.46 TiB

---

## Network Configuration

- **Primary IP:** 10.10.1.15
- **Hostname:** truenas
- **Web UI:** https://truenas.lab.oreki.io/

---

## Running Applications

### Media Management Services (arr stack)

All running as TrueNAS SCALE Apps on pool1:

1. **TrueNAS - Sonarr** - TV show automation

   - URL: https://sonarr.lab.oreki.io
2. **TrueNAS - Radarr** - Movie automation

   - URL: https://radarr.lab.oreki.io
3. **TrueNAS - Bazarr** - Subtitle automation

   - URL: https://bazarr.lab.oreki.io
4. **TrueNAS - Prowlarr** - Indexer manager

   - URL: https://prowlarr.lab.oreki.io
5. **TrueNAS - SABnzbd** - Usenet downloader

   - URL: https://sabnzbd.lab.oreki.io
6. **TrueNAS - Overseerr** - Media request system

   - URL: https://overseerr.lab.oreki.io
7. **TrueNAS - Recyclarr** - Quality profile manager

   - Syncs TRaSH guides to Sonarr/Radarr
8. **TrueNAS - Flaresolverr** - Cloudflare bypass
