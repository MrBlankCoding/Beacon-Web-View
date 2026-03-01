# CLI Reference

The Beacon CLI is used to package your web applications into native macOS `.app` bundles and to run them in development mode.

## `build`

Package a web project into a native macOS `.app` bundle.

```bash
beacon build <project-dir> [options]
```

### Arguments

- `<project-dir>`: Path to the project directory containing your `runtime.config.json`.

### Options

- `--output <path>`: Output directory for the `.app` bundle. (Default: `.`)
- `--name <name>`: The name of the application. (Default: derived from project directory)
- `--bundleId <id>`: The bundle identifier (e.g., `com.example.myapp`). (Default: `com.beacon.<name>`)
- `--icon <path>`: Path to an `.icns` file to embed in the app bundle.
- `--runtime <path>`: Path to a prebuilt `BeaconRuntime` binary.
- `--signIdentity <identity>`: Code signing identity. (Default: ad-hoc `-`)
- `--skipSign`: Skip code signing the packaged app.
- `--skipRuntimeBuild`: Skip automatic BeaconRuntime build if the binary is missing.
- `--no-incremental`: Disable incremental packaging.

---

## `dev`

Run the Beacon runtime against a live development server with hot reload support.

```bash
beacon dev <project-dir> [options]
```

### Arguments

- `<project-dir>`: Path to the project directory containing your `runtime.config.json`.

### Options

- `--url <url>`: The URL of your development server. (Default: `http://localhost:5173`)
- `--runtime <path>`: Path to a prebuilt `BeaconRuntime` binary.
- `--skipRuntimeBuild`: Skip automatic BeaconRuntime build if the binary is missing.
