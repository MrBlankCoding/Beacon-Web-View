# CLI Reference

Beacon CLI packages web projects as native macOS `.app` bundles and runs dev mode.

## `build`

```bash
beacon build <project-dir> [options]
```

Creates a packaged app bundle.

### Arguments

- `<project-dir>`: project directory containing `runtime.config.json`

### Options

- `--output <path>`: output directory (default `.`)
- `--name <name>`: app name (default derived from directory)
- `--bundleId <id>`: bundle identifier (default `com.beacon.<name>`)
- `--icon <path>`: `.icns` icon path
- `--runtime <path>`: explicit `BeaconRuntime` binary path
- `--signIdentity <identity>`: codesign identity (default `-` ad-hoc)
- `--skipSign`: skip code signing
- `--skipRuntimeBuild`: do not auto-build runtime if missing
- `--no-incremental`: disable incremental packaging

## `dev`

```bash
beacon dev <project-dir> [options]
```

Runs runtime against a live dev server URL.

### Arguments

- `<project-dir>`: project directory containing `runtime.config.json`

### Options

- `--url <url>`: dev server URL (default `http://localhost:5173`)
- `--runtime <path>`: explicit `BeaconRuntime` binary path
- `--skipRuntimeBuild`: do not auto-build runtime if missing
