# TrueNAS App Deployment Guide

**Purpose:** Generic guide for deploying applications on TrueNAS (Claude helped format and rewrite my notes for clarity.

---

## Prerequisites

Before deploying any app on TrueNAS:

1. ✅ TrueNAS SCALE installed (Community Edition 25.04.2.5+)
2. ✅ Storage pool created
3. ✅ Datasets created for app configs and data
4. ✅ Network configuration complete (static IP assigned)

---

## General App Deployment Process

### Step 1: Create Storage Datasets

**Best Practice:** Create dedicated datasets for:

- App configuration files
- App data/media storage

```bash
# Recommended structure:
mkdir /mnt/pool1/media/{structure}      # media storage
mkdir /mnt/pool3/appdata/{app_name}     # Config files
```

**Example for Sonarr:**

```
/mnt/pool3/appdata/sonarr          # Sonarr config
```

### Step 2: Set Permissions

TrueNAS apps run as UID/GID `568` by default.

```bash
# Via SSH or Shell:
chown -R 568:568 /mnt/pool3/appdata/{app_name}
chmod -R 755 /mnt/pool3/appdata/{app_name}
```

### Step 3: Deploy the App

**In TrueNAS Web UI:**

1. Navigate to **Apps** → **Discover Apps**
2. Search for the application
3. Click **Install**
4. Configure the app:

#### Application Configuration

- **Application Name:** Use lowercase, no spaces (e.g., `sonarr`)
- **Version:** Select stable or latest
- **Timezone:** `America/New_York` (or your timezone)

#### Storage Configuration

Configure **Host Path** → **Mount Path** mappings:

| Purpose   | Host Path (TrueNAS)          | Mount Path (Container) |
| --------- | ---------------------------- | ---------------------- |
| Config    | `/mnt/pool3/appdata/sonarr`  | `/config`              |
| TV Shows  | `/mnt/pool1/media/tv`        | `/tv`                  |
| Downloads | `/mnt/pool1/media/downloads` | `/downloads`           |

**Important Notes:**

- **Host Path** = actual path on TrueNAS filesystem
- **Mount Path** = path inside the container (what the app sees)
- Mount Path usually starts with `/` and follows app conventions

#### Network Configuration

- **Network Mode:** Bridge (default)
- **Host Network:** Only if app requires direct network access
- **Port Mapping:**
  - Web UI port (e.g., 8989 for Sonarr)
  - Additional ports if needed

**Port Selection Best Practices:**

- Document custom ports in Obsidian
- Avoid conflicts with other services

#### Environment Variables (Optional)

Some apps require additional configuration:

- `PUID=568` (User ID)
- `PGID=568` (Group ID)
- Custom API keys
- Feature flags

### Step 4: Deploy & Verify

1. Click **Save** to deploy the app
2. Wait for deployment (can take 1-5 minutes)
3. Check **Apps** page for status:
   - 🟢 **Active** = Running successfully
   - 🔴 **Stopped** = Check logs for errors
   - 🟡 **Deploying** = Wait for completion

### Step 5: Initial Configuration

1. Access the app's Web UI:

   ```
   http://{truenas_ip}:{app_port}
   ```

   Example: `http://10.10.1.15:8989` (Sonarr)

2. Complete initial setup wizard (if applicable)
3. Configure paths to match Mount Paths from Step 3
4. Test functionality
