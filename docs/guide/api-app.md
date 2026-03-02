# App API (`window.beacon.app`)

Application metadata and window lifecycle helpers.

## Permissions

No permission required.

## Methods

### `getVersion(): Promise<string>`
Returns the runtime version string.

### `getConfig(): Promise<object>`
Returns the loaded runtime config object.

### `openWindow(): Promise<string>`
Opens a new native window and resolves with `"ok"`.

## Example

```js
const version = await window.beacon.app.getVersion();
const config = await window.beacon.app.getConfig();

console.log(version, config.entry);
await window.beacon.app.openWindow();
```
