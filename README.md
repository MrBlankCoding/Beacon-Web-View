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
Optional: pass `--icon /path/to/AppIcon.icns` to embed a custom app icon.

### Dev Mode (Hot Reload)

Use your frontend dev server directly instead of a built folder:

```bash
cd sample
npm run dev
```

```bash
cd cli && swift build
./.build/debug/beacon dev ../sample --url http://localhost:5173
```