# USB Multi-Mounter

Automatically mounts configured USB drives to persistent mount points in Home Assistant OS.

## Features

- 🔍 **Automatic Discovery** - Scans and lists all connected USB drives
- 📌 **Persistent Mounting** - Keeps drives mounted at consistent locations
- 🔄 **Hot-Plug Support** - Detects new drives when connected
- 📊 **Drive Information** - Shows size, format, label, and mount status

## Supported Filesystem Formats

Home Assistant OS supports the following filesystem formats for USB drives:

### Recommended Formats

1. **ext4** (Best for Linux/Home Assistant)
   - ✅ Full Linux permissions support
   - ✅ Best performance
   - ✅ Native support in Home Assistant OS
   - ⚠️ Not readable on Windows/Mac without additional software

2. **exFAT** (Best for cross-platform compatibility)
   - ✅ Works on Windows, Mac, and Linux
   - ✅ No file size limits
   - ✅ Good for media files
   - ⚠️ May require kernel module (usually included in HA OS)

3. **NTFS** (Windows filesystem)
   - ✅ Readable/writable in most systems
   - ⚠️ Requires `ntfs-3g` driver (may have limited performance)

4. **FAT32/vfat** (Maximum compatibility)
   - ✅ Universal compatibility
   - ❌ 4GB file size limit
   - ❌ No permissions support
   - ⚠️ Only use for small storage needs

### How to Format Your USB Drive

#### On Linux:
```bash
# For ext4 (recommended)
sudo mkfs.ext4 -L "MyDrive" /dev/sdX1

# For exFAT
sudo mkfs.exfat -n "MyDrive" /dev/sdX1
```

#### On Windows:
1. Right-click the drive in File Explorer
2. Select "Format"
3. Choose **exFAT** or **NTFS**
4. Assign a volume label
5. Click "Start"

#### On Mac:
1. Open Disk Utility
2. Select your USB drive
3. Click "Erase"
4. Choose **exFAT** or **MS-DOS (FAT)**
5. Name the drive and click "Erase"

## Configuration

### Viewing Discovered Drives

After installing the add-on, check the logs to see all discovered drives. The add-on creates a file at `/data/discovered_drives.json` with information about all connected drives.

### Example Configuration

```yaml
drives:
  - device: /dev/sda1
    label: "Media"
    mount_point: /media/usb1
  - device: /dev/sdb1
    label: "Backup"
    mount_point: /share/usb_backup
```

### Choosing the Right Mount Point

Home Assistant has several shared directories that are accessible across add-ons:

- **`/media/`** - Best for media files (photos, videos, music)
  - ✅ Accessible by Media Browser
  - ✅ Accessible by most media add-ons (Plex, Jellyfin, etc.)
  - ✅ Visible in File Editor

- **`/share/`** - Best for general storage and backups
  - ✅ Accessible by all add-ons that request `share` access
  - ✅ Common location for backups and shared files
  - ✅ Visible in File Editor and Terminal

- **`/backup/`** - For Home Assistant backups
  - ✅ Used by the backup system
  - ⚠️ Requires special access permissions

- **`/config/`** - For configuration files
  - ⚠️ Not recommended for USB mounts (security risk)

**Recommendation:** Use `/media/` for media content and `/share/` for everything else.

### Configuration Options

- **device**: The device path (e.g., `/dev/sda1`) - found in discovery logs
- **label**: A friendly name for the drive
- **mount_point**: Where to mount the drive (usually under `/media/`)

## Finding Your Device Path

1. Install and start the add-on
2. Check the add-on logs - you'll see output like:

```json
[
  {
    "device": "/dev/sda1",
    "size": "128G",
    "fstype": "ext4",
    "label": "MyUSB",
    "uuid": "1234-5678",
    "mountpoint": null,
    "mounted": false
  }
]
```

3. Look for unmounted drives (`"mounted": false`)
4. Use the `device` value in your configuration

## Troubleshooting

### Drive Not Mounting

1. **Check the filesystem format** - Use `lsblk -f` to verify the filesystem type
2. **Ensure it's formatted** - Unformatted drives won't mount
3. **Check for errors** in the add-on logs
4. **Try reformatting** the drive to ext4 or exFAT

### Permission Issues

- ext4 drives support full Linux permissions
- FAT32/exFAT don't support permissions - all files appear as owned by root
- NTFS may have limited permission support

### Drive Not Detected

- USB drive may need more power - try a powered USB hub
- Check that the drive is visible in Home Assistant OS: System → Hardware
- Restart the add-on after connecting a new drive

### Files Not Showing in Media Browser

1. **Check mount location** - Media Browser only scans `/media/`
2. **Restart Home Assistant** - May need to refresh media sources
3. **Check file permissions** - Files should be readable
4. **Verify mount succeeded** - Check add-on logs for mount confirmation

### Other Add-ons Can't See the Drive

Some add-ons may need explicit configuration to access mounted drives:

**Example: Configuring Studio Code Server**
Add to the add-on configuration:
```yaml
init_commands:
  - mkdir -p /config/usb_link
  - ln -s /media/usb1 /config/usb_link/usb1
```

**Example: Checking Access from Terminal**
```bash
ls -la /media/usb1
df -h | grep usb
```

If you don't see your mount, the add-on may not have `media` or `share` mapped in its configuration.

## Advanced Usage

### Accessing Mounted Drives from Home Assistant

Once mounted, your drives are accessible from:

#### Media Browser
If mounted under `/media/`, the content appears automatically in:
- Settings → Media → Media Browser
- Media source selector in automations and scripts
- Any integration that uses the media browser

#### Other Add-ons
Add-ons can access your mounted drives if they have the appropriate mappings:

**For media files** (`/media/`):
- Plex, Jellyfin, Emby
- Music Assistant
- Frigate (for recordings)
- Any add-on with `media:rw` or `media:ro` in its config

**For general storage** (`/share/`):
- File Editor
- Terminal & SSH
- Samba Share
- Any add-on with `share:rw` in its config

#### Example: Accessing in File Editor
1. Install "File Editor" add-on
2. Navigate to `/media/usb1/` or `/share/usb_backup/`
3. View and edit files directly

#### Example: Using with Samba Share
1. Install "Samba Share" add-on
2. Your USB mounts under `/media/` and `/share/` are automatically included
3. Access from Windows/Mac network browser

#### Example: Using in Automations
```yaml
service: media_player.play_media
data:
  media_content_id: media-source://media_source/local/usb1/music/song.mp3
  media_content_type: music
target:
  entity_id: media_player.living_room
```

### Using UUID Instead of Device Path

For more stable mounting (device paths can change), you can use UUID:

```yaml
drives:
  - device: /dev/disk/by-uuid/1234-5678-90ab-cdef
    label: "Media"
    mount_point: /media/usb1
```

Find the UUID in the discovery output or using `lsblk -f`.

## Support

For issues or questions, please visit:
https://github.com/jptrsn/home-assistant-add-ons/issues