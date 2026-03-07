# API Overview

Beacon provides a bridge to native macOS APIs. You can interact with these APIs using the **official TypeScript SDK**.

## Official SDK

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

## Available Namespaces

| Namespace | Object | Permission Required |
| --- | --- | --- |
| App | `app` | No |
| Clipboard | `clipboard` | No |
| Dialog | `dialog` | No |
| Filesystem | `fs` | `permissions.filesystem` |
| Menu | `menu` | No |
| Notifications | `notifications` | `permissions.notifications` |
| Shell | `shell` | `permissions.shell` |
| Shortcuts | `shortcuts` | No |
| System | `system` | No |
| Theme | `theme` | No |
| Tray | `tray` | No |
| Window | `browserWindow` | No |

## Events

The SDK provides a clean, listener-based event system.

```typescript
import { tray, shortcuts, theme } from '@beacon-web-view/api';

// Listen for tray clicks
tray.onClick((id) => {
  console.log(`Tray item clicked: ${id}`);
});

// Listen for global shortcuts
shortcuts.onTrigger((combo) => {
  console.log(`Global shortcut triggered: ${combo}`);
});

// Listen for theme changes
theme.onThemeChange((newTheme) => {
  console.log(`Theme is now ${newTheme}`);
});
```
