# TRMNL Server

Self-hosted TRMNL server for displaying Home Assistant data on e-ink devices like Kobo e-readers.

## About

This add-on runs a TRMNL-compatible server locally on your Home Assistant instance. Display weather, calendars, and other HA data on your Kobo e-reader.

## Installation

1. Add the repository to Home Assistant
2. Install the TRMNL Server add-on
3. Start the add-on
4. Configure your Kobo to point to: `http://homeassistant.local:8080/api`

## Configuration

**refresh_interval**: Minimum seconds between device refreshes (default: 300)

## Support

[Open an issue](https://github.com/jptrsn/home-assistant-add-ons/issues)