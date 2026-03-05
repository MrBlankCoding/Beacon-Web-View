# API Overview

Beacon provides a bridge to native macOS APIs. You can interact with these APIs using the **official TypeScript SDK** (recommended) or the injected `window.beacon` object.

## Official SDK (Recommended)

For the best developer experience, including full **TypeScript types** and **auto-completion**, use the `@beacon-web-view/api` package.

### Installation

```bash
npm install @beacon-web-view/api
```

### Usage

```typescript
import { app, notifications } from '@beacon-web-view/api';

async function init() {
  const version = await app.getVersion();
  await notifications.send("Beacon", `Running version ${version}`);
}
```

## Low-level Bridge (`window.beacon`)

If you are not using a bundler, Beacon injects a `window.beacon` object into your renderer.

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

## Events

The SDK provides a clean, listener-based event system.

```typescript
import { tray, shortcuts } from '@beacon-web-view/api';

// Listen for tray clicks
tray.onClick((id) => {
  console.log(`Tray item clicked: ${id}`);
});

// Listen for global shortcuts
shortcuts.onTrigger((combo) => {
  console.log(`Global shortcut triggered: ${combo}`);
});
```

### Low-level DOM Events

Beacon also dispatches standard DOM events:

- `beacon-tray-click` with `event.detail` = menu item id (string)
- `beacon-shortcut` with `event.detail` = normalized shortcut string
- `beacon-menu-click` with `event.detail` = menu item id (string)
