# Configuration

## refresh_interval
Minimum time in seconds between device refresh requests. Default is 300 (5 minutes).

## Using with Kobo

Configure your Kobo's `config.json`:
```json
{
  "TrmnlId": "YOUR:KOBO:MAC:ADDRESS",
  "TrmnlToken": "any-token",
  "TrmnlApiUrl": "http://homeassistant.local:8080/api",
  "LoopMaxIteration": 0,
  "ImageFormat": "png"
}
```

The add-on has full access to Home Assistant entities for creating custom displays.