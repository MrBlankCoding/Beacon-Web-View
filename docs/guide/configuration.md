# Configuration

Beacon is configured with a `runtime.config.json` file at your app root.

## Full Example

```json
{
  "window": {
    "width": 1000,
    "height": 700,
    "resizable": true,
    "title": "Beacon Sample App",
    "frame": false,
    "vibrancy": {
      "enabled": true,
      "material": "sidebar"
    }
  },
  "permissions": {
    "filesystem": ["$DOCUMENTS", "$DESKTOP"],
    "notifications": true,
    "shell": false
  },
  "entry": "build/index.html"
}
```

## Top-Level Fields

### `window` (required)

Native window configuration.

- `width` (`number`, required)
- `height` (`number`, required)
- `resizable` (`boolean`, default `true`)
- `title` (`string`, optional)
- `frame` (`boolean`, default `true`)
- `vibrancy` (`object`, optional)
  - `enabled` (`boolean`)
  - `material` (`string`, for example `sidebar`, `menu`, `popover`, `content`, `window`)

### `permissions` (optional)

Permission gates for sensitive APIs.

- `filesystem` (`boolean | string[]`, default `false`)
  - `true`: full access
  - `false`: disabled
  - `string[]`: scoped access paths
- `notifications` (`boolean`, default `false`)
- `shell` (`boolean`, default `false`)
- `microphone` (`boolean`, default `false`): Required for `getUserMedia` audio.
- `camera` (`boolean`, default `false`): Required for `getUserMedia` video.
- `screen` (`boolean`, default `false`): Required for `getDisplayMedia` screen sharing.

Supported path tokens for `filesystem` scopes:

- `$HOME`
- `$DOCUMENTS`
- `$DESKTOP`
- `$DOWNLOADS`
- `$APP_DATA`

### `entry` (required)

Relative path to your app HTML entry file (for example `build/index.html`).

## API-to-Permission Map

- `window.beacon.fs` -> `permissions.filesystem`
- `window.beacon.notifications` -> `permissions.notifications`
- `window.beacon.shell` -> `permissions.shell`
- `navigator.mediaDevices.getUserMedia` -> `permissions.microphone` / `permissions.camera`
- `navigator.mediaDevices.getDisplayMedia` -> `permissions.screen`
