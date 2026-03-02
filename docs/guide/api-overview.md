# API Overview

Beacon injects a `window.beacon` object into your renderer with native macOS APIs.

## Availability

All namespaces below are available by default, but some methods are permission-gated by `runtime.config.json`.

| Namespace | Object | Permission Required |
| --- | --- | --- |
| App | `window.beacon.app` | No |
| Clipboard | `window.beacon.clipboard` | No |
| Dialog | `window.beacon.dialog` | No |
| Filesystem | `window.beacon.fs` | `permissions.filesystem` |
| Menu | `window.beacon.menu` | No |
| Notifications | `window.beacon.notifications` | `permissions.notifications` |
| Shell | `window.beacon.shell` | `permissions.shell` |
| Shortcuts | `window.beacon.shortcuts` | No |
| System | `window.beacon.system` | No |
| Tray | `window.beacon.tray` | No |

## Event Hooks

Beacon dispatches DOM events and also mirrors them to convenience callbacks:

- `beacon-tray-click` with `event.detail` = menu item id (string)
- `beacon-shortcut` with `event.detail` = normalized shortcut string
- `beacon-menu-click` with `event.detail` = menu item id (string)

Convenience callback aliases:

- `window.onBeaconTrayClick = (id) => { ... }`
- `window.onBeaconShortcut = (combo) => { ... }`
- `window.onBeaconMenuClick = (id) => { ... }`

## Basic Example

```js
const version = await window.beacon.app.getVersion();
await window.beacon.notifications.send("Beacon", `Running ${version}`);
```
