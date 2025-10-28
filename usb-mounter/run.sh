#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

if [ ! -f "$CONFIG_PATH" ]; then
  echo "No configuration found at $CONFIG_PATH"
  exit 1
fi

echo "Starting USB Multi-Mounter..."
jq -c '.drives[]?' "$CONFIG_PATH" | while read -r drive; do
  DEVICE=$(echo "$drive" | jq -r '.device')
  LABEL=$(echo "$drive" | jq -r '.label')
  MOUNT_POINT=$(echo "$drive" | jq -r '.mount_point')

  if [ -z "$DEVICE" ] || [ -z "$MOUNT_POINT" ]; then
    echo "⚠️ Skipping invalid entry: $drive"
    continue
  fi

  mkdir -p "$MOUNT_POINT"

  echo "Mounting $DEVICE ($LABEL) → $MOUNT_POINT"
  mount "$DEVICE" "$MOUNT_POINT" || echo "❌ Failed to mount $DEVICE"
done

echo "All configured drives processed."
tail -f /dev/null  # keep container running
