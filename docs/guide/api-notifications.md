# Notifications API (`window.beacon.notifications`)

Send native macOS user notifications.

## Permissions

Requires `permissions.notifications: true`.

Notifications only work when Beacon is running from a packaged `.app` bundle.

## Methods

### `send(title: string, body?: string): Promise<string>`
Sends a notification and resolves with `"ok"`.

If the OS permission is denied, the Promise rejects with a user-facing error.

## Example

```js
await window.beacon.notifications.send(
  "Build complete",
  "Your export finished successfully."
);
```
