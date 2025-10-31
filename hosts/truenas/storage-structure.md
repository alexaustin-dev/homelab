# Storage Structure

## Media Dataset (pool1/media)

```
/mnt/pool1/media/
├── tv/              # TV shows - organized by Sonarr
├── movies/          # Movies - organized by Radarr
└── downloads/       # SABnzbd download directory
```

**NFS Exports:**

- `/mnt/pool1/media/tv`
- `/mnt/pool1/media/movies`

### App Configuration Storage (pool1/appdata)

```
/mnt/pool3/appdata/
├── sonarr/          # Sonarr config and database
├── radarr/          # Radarr config and database
├── bazarr/          # Bazarr config and database
├── prowlarr/        # Prowlarr config and database
├── sabnzbd/         # SABnzbd config and queue
└── overseerr/       # Overseerr config and database
```
