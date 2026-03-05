# Filesystem API (`fs`)

Permission-gated filesystem access.

## Usage

```typescript
import { fs } from '@beacon-web-view/api';
```

## Permissions

Requires `permissions.filesystem` in `runtime.config.json`.

```json
{
  "permissions": {
    "filesystem": true
  }
}
```

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

### `writeFile(path: string, content: string): Promise<void>`
Writes UTF-8 content, creating parent directories as needed.

### `listDirectory(path: string): Promise<string[]>`
Returns sorted file/folder names in the directory.

### `exists(path: string): Promise<boolean>`
Checks whether a file or directory exists.

### `isDirectory(path: string): Promise<boolean>`
Returns `true` when the path exists and is a directory.

## Example

```typescript
import { fs } from '@beacon-web-view/api';

const entries = await fs.listDirectory("$DESKTOP");

const reportPath = "$DOCUMENTS/beacon/report.txt";
await fs.writeFile(reportPath, "Beacon report\n");

const content = await fs.readFile(reportPath);
console.log(entries, content);
```
