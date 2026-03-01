# JavaScript API

Beacon injects a `window.beacon` object into your web app, providing access to native macOS APIs.

## Filesystem (`window.beacon.fs`)

Requires `permissions.filesystem: true` in `runtime.config.json`.

### `readFile(path: string): Promise<string>`

Reads the contents of a file as a string. Supports `~` for the home directory.

```javascript
const content = await window.beacon.fs.readFile('~/Documents/hello.txt');
```

### `writeFile(path: string, content: string): Promise<string>`

Writes a string to a file. Creates directories if they don't exist.

```javascript
await window.beacon.fs.writeFile('~/Documents/output.txt', 'Hello, World!');
```

### `listDirectory(path: string): Promise<string[]>`

Lists the files and folders in a directory.

```javascript
const entries = await window.beacon.fs.listDirectory('~/Desktop');
```

### `exists(path: string): Promise<boolean>`

Checks if a file or directory exists.

```javascript
const fileExists = await window.beacon.fs.exists('~/some/path');
```

### `isDirectory(path: string): Promise<boolean>`

Checks if the given path is a directory.

```javascript
const isDir = await window.beacon.fs.isDirectory('~/some/path');
```

---

## Notifications (`window.beacon.notifications`)

Requires `permissions.notifications: true` in `runtime.config.json`.

### `send(title: string, body: string): Promise<string>`

Sends a system notification.

```javascript
await window.beacon.notifications.send('Hello!', 'This is a notification from Beacon.');
```

---

## Shell (`window.beacon.shell`)

Requires `permissions.shell: true` in `runtime.config.json`.

### `exec(command: string): Promise<string>`

Executes a command through `/bin/zsh -lc` and returns the output (stdout + stderr).

```javascript
const output = await window.beacon.shell.exec('ls -la');
```

---

## App Info (`window.beacon.app`)

Always available.

### `getVersion(): Promise<string>`

Returns the current Beacon runtime version.

```javascript
const version = await window.beacon.app.getVersion();
```

### `getConfig(): Promise<object>`

Returns the active `runtime.config.json` configuration as an object.

```javascript
const config = await window.beacon.app.getConfig();
console.log('App title:', config.window.title);
```
