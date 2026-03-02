# Getting Started

Package a static web app into a native macOS app using Beacon.

## Prerequisites

- macOS
- Swift toolchain
- Node.js (for your web app)

## 1. Clone Beacon

```bash
git clone https://github.com/MrBlankCoding/Beacon-Web-View
cd Beacon-Web-View
```

## 2. Build Your Web App

In your web project:

```bash
npm run build
```

## 3. Create `runtime.config.json`

```json
{
  "window": {
    "width": 1000,
    "height": 700,
    "resizable": true,
    "title": "My Beacon App"
  },
  "permissions": {
    "filesystem": true,
    "notifications": true,
    "shell": false
  },
  "entry": "dist/index.html"
}
```

## 4. Build the CLI

```bash
cd cli
swift build
```

## 5. Package a macOS App

```bash
./.build/debug/beacon build /path/to/my-web-app --output /path/to/output --name MyBeaconApp
```

The generated bundle will be:

- `/path/to/output/MyBeaconApp.app`

## Dev Mode (Hot Reload)

1. Start your web dev server (for example Vite):

```bash
npm run dev
```

2. Run Beacon in dev mode:

```bash
./.build/debug/beacon dev /path/to/my-web-app --url http://localhost:5173
```
