#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json
DISCOVERY_FILE=/data/discovered_drives.json

# Function to discover all block devices
discover_drives() {
  echo "🔍 Discovering USB drives..."

  # Get all block devices with their properties
  lsblk -J -o NAME,SIZE,TYPE,FSTYPE,LABEL,UUID,MOUNTPOINT,MODEL | \
    jq '[.blockdevices[] |
      select(.type == "part" or .type == "disk") |
      {
        device: ("/dev/" + .name),
        size: .size,
        fstype: .fstype,
        label: .label,
        uuid: .uuid,
        mountpoint: .mountpoint,
        model: .model,
        mounted: (.mountpoint != null)
      }]' > "$DISCOVERY_FILE"

  echo "📋 Discovered drives saved to $DISCOVERY_FILE"
  cat "$DISCOVERY_FILE" | jq '.'
}

# Function to mount configured drives
mount_drives() {
  if [ ! -f "$CONFIG_PATH" ]; then
    echo "⚠️ No configuration found at $CONFIG_PATH"
    return
  fi

  echo "🔧 Mounting configured drives..."
  jq -c '.drives[]?' "$CONFIG_PATH" | while read -r drive; do
    DEVICE=$(echo "$drive" | jq -r '.device')
    LABEL=$(echo "$drive" | jq -r '.label')
    MOUNT_POINT=$(echo "$drive" | jq -r '.mount_point')

    if [ -z "$DEVICE" ] || [ -z "$MOUNT_POINT" ]; then
      echo "⚠️ Skipping invalid entry: $drive"
      continue
    fi

    # Check if device exists
    if [ ! -b "$DEVICE" ]; then
      echo "❌ Device $DEVICE not found"
      continue
    fi

    # Create mount point if it doesn't exist
    mkdir -p "$MOUNT_POINT"

    # Check if already mounted
    if mountpoint -q "$MOUNT_POINT"; then
      echo "✓ $MOUNT_POINT already mounted"
      continue
    fi

    echo "📌 Mounting $DEVICE ($LABEL) → $MOUNT_POINT"

    # Try to mount with automatic filesystem detection
    if mount "$DEVICE" "$MOUNT_POINT" 2>/dev/null; then
      echo "✓ Successfully mounted $DEVICE"
    else
      # Try with explicit filesystem types
      for FSTYPE in ext4 ntfs vfat exfat; do
        if mount -t "$FSTYPE" "$DEVICE" "$MOUNT_POINT" 2>/dev/null; then
          echo "✓ Successfully mounted $DEVICE as $FSTYPE"
          break
        fi
      done || echo "❌ Failed to mount $DEVICE - check filesystem format"
    fi
  done
}

# Initial discovery
discover_drives

# Mount configured drives
mount_drives

echo ""
echo "✅ USB Multi-Mounter is running"
echo "📊 View discovered drives at: $DISCOVERY_FILE"
echo ""

# Monitor for new USB devices and re-discover
echo "👀 Monitoring for USB device changes..."
while true; do
  # Wait for USB events (this will detect new connections)
  inotifywait -e create,delete -q /dev/ 2>/dev/null || true
  sleep 2
  discover_drives
  mount_drives
done