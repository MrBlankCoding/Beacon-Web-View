# Getting Started

Beacon Web View allows you to package any static web project into a native macOS application using the system's native WebKit engine.

## Prerequisites

- macOS
- [Swift](https://swift.org/download/) (for the CLI and runtime)
- [Node.js](https://nodejs.org/) (for your web project)

## Installation

Currently, Beacon is in early development. You can clone the repository to get started:

```bash
git clone https://github.com/MrBlankCoding/Beacon-Web-View
cd beacon
```

## Creating Your First App

### 1. Prepare Your Web Project

Ensure your web project (e.g., Vite, React, Svelte) is built into a static directory (usually `dist` or `build`).

```bash
cd my-web-app
npm run build
```

### 2. Configure Beacon

Create a `runtime.config.json` file in your web project's root:

```json
{
  "window": {
    "width": 800,
    "height": 600,
    "title": "My Beacon App"
  },
  "entry": "dist/index.html"
}
```

### 3. Build the CLI

```bash
cd beacon/cli
swift build
```

### 4. Package Your App

Use the Beacon CLI to package your app into a native macOS bundle:

```bash
./beacon/cli/.build/debug/beacon build ./my-web-app --output ./output --name MyBeaconApp
```

Your app will be available in the `./output` directory as `MyBeaconApp.app`.

## Development Mode

Beacon supports hot-reloading by pointing the runtime to your development server:

1. Start your web app's dev server: `npm run dev`
2. Run Beacon in dev mode:

```bash
./beacon/cli/.build/debug/beacon dev ./my-web-app --url http://localhost:5173
```
