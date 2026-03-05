# Notifications API (`notifications`)

Send native macOS user notifications.

## Usage

```typescript
import { notifications } from '@beacon-web-view/api';
```

## Permissions

Requires `permissions.notifications: true`.

Notifications only work when Beacon is running from a packaged `.app` bundle.

## Methods

### `send(title: string, body?: string): Promise<void>`
Sends a notification.

If the OS permission is denied, the Promise rejects with a user-facing error.

## Example

```typescript
import { notifications } from '@beacon-web-view/api';

await notifications.send(
  "Build complete",
  "Your export finished successfully."
);
```
