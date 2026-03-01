# Configuration

Beacon apps are configured using a `runtime.config.json` file in the root of your project.

## Example Configuration

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
    "filesystem": true,
    "notifications": true,
    "shell": true
  },
  "entry": "dist/index.html"
}
```

## Options

### `window`

Configure the appearance and behavior of the application window.

- `width`: Initial window width (number).
- `height`: Initial window height (number).
- `resizable`: Whether the window is resizable (boolean, default: `true`).
- `title`: The title displayed in the title bar (string).
- `frame`: Whether to show the standard macOS window frame (boolean, default: `true`).
- `vibrancy`: Enable macOS vibrancy effects.
  - `enabled`: Whether vibrancy is enabled (boolean).
  - `material`: The vibrancy material (e.g., `"sidebar"`, `"menu"`, `"popover"`, `"content"`, `"window"`).

### `permissions`

Gated APIs require explicit permissions to be enabled in this section.

- `filesystem`: Enable `window.beacon.fs` (boolean, default: `false`).
- `notifications`: Enable `window.beacon.notifications` (boolean, default: `false`).
- `shell`: Enable `window.beacon.shell` (boolean, default: `false`).

### `entry`

The relative path to your web app's main HTML file (string).
For production, this should point to your built `index.html`.
In development, Beacon will typically point to your dev server's URL instead.
