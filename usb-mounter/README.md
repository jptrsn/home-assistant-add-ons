# USB Multi-Mounter

Automatically mounts configured USB drives to persistent mount points in Home Assistant OS.

## Configuration

Example:

```yaml
drives:
  - device: /dev/sda1
    label: "Media"
    mount_point: /media/usb1
