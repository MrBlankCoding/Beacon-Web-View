# Beacon

> A WebKit-based desktop runtime that converts static web projects into native macOS apps

Beacon is just a hobby project of mine, so don't expect too much. HOWEVER, the resulting package when compared to electron which is around 300-200mb is only 5-10mb depending on the app size.

## Quick Start

### Build

```bash
cd sample
npm install
npm run build
```

### 4. Package

```bash
cd cli && swift build
./.build/debug/beacon build ../sample --output ../output --name SampleApp
```

Optional: pass `--runtime /path/to/BeaconRuntime` to use a specific binary.

## JavaScript API

Beacon injects a `window.beacon` API into your web app:

### Filesystem (requires `permissions.filesystem: true`)

```javascript
const content = await window.beacon.fs.readFile('~/Documents/file.txt');
await window.beacon.fs.writeFile('~/Documents/output.txt', 'Hello!');
const entries = await window.beacon.fs.listDirectory('~/Desktop');
const exists = await window.beacon.fs.exists('~/some/path');
```

### Notifications (requires `permissions.notifications: true`)

```javascript
await window.beacon.notifications.send('Title', 'Body text');
```

### App Info (always available)

```javascript
const version = await window.beacon.app.getVersion();
const config = await window.beacon.app.getConfig();
```

## Architecture

```
┌──────────────────────────────┐
│        Web Content           │
│     (WKWebView Renderer)     │
├──────────────────────────────┤
│      window.beacon API       │
├──────────────────────────────┤
│    BridgeHandler (IPC)       │
├──────────────────────────────┤
│   APIManager (Permission)    │
├───────────┬──────────────────┤
│ Filesystem│  Notifications   │
└───────────┴──────────────────┘
```
