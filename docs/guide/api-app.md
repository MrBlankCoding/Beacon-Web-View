# App API (`app`)

Application metadata and window lifecycle helpers.

## Usage

```typescript
import { app } from '@beacon-web-view/api';
```

## Permissions

No permission required.

## Methods

### `getVersion(): Promise<string>`
Returns the runtime version string.

### `getConfig(): Promise<object>`
Returns the loaded runtime config object.

### `openWindow(url?: string): Promise<void>`
Opens a new native window.

## Example

```typescript
import { app } from '@beacon-web-view/api';

const version = await app.getVersion();
const config = await app.getConfig();

console.log(version, config.entry);
await app.openWindow();
```
