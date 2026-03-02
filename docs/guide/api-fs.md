# Filesystem API (`window.beacon.fs`)

Permission-gated filesystem access.

## Permissions

Requires `permissions.filesystem` in `runtime.config.json`.

```json
{
  "permissions": {
    "filesystem": ["$DOCUMENTS", "$DESKTOP"]
  }
}
```

Supported values:

- `false`: disabled
- `true`: full filesystem access
- `string[]`: scoped directories

Path tokens supported in scoped values and method inputs:

- `$HOME`
- `$DOCUMENTS`
- `$DESKTOP`
- `$DOWNLOADS`
- `$APP_DATA`
- `~` (home directory)

## Methods

### `readFile(path: string): Promise<string>`
Reads a UTF-8 file.

### `writeFile(path: string, content: string): Promise<string>`
Writes UTF-8 content, creating parent directories as needed. Resolves with `"ok"`.

### `listDirectory(path: string): Promise<string[]>`
Returns sorted file/folder names in the directory.

### `exists(path: string): Promise<boolean>`
Checks whether a file or directory exists.

### `isDirectory(path: string): Promise<boolean>`
Returns `true` when the path exists and is a directory.

## Example

```js
const entries = await window.beacon.fs.listDirectory("$DESKTOP");

const reportPath = "$DOCUMENTS/beacon/report.txt";
await window.beacon.fs.writeFile(reportPath, "Beacon report\n");

const content = await window.beacon.fs.readFile(reportPath);
console.log(entries, content);
```
