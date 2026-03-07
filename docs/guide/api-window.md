# Window API (`browserWindow`)

Control the current application window.

## Usage

```typescript
import { browserWindow } from '@beacon-web-view/api';
```

## Permissions

No permission required.

## Methods

### `minimize(): Promise<void>`
Minimizes the window to the Dock.

### `maximize(): Promise<void>`
Maximizes (zooms) the window.

### `close(): Promise<void>`
Closes the window.

### `focus(): Promise<void>`
Brings the window to the front and gives it focus.

### `setFullscreen(fullscreen: boolean): Promise<void>`
Enters or exits fullscreen mode.

### `isMaximized(): Promise<boolean>`
Returns true if the window is currently maximized.

### `isMinimized(): Promise<boolean>`
Returns true if the window is currently minimized.

### `isFullscreen(): Promise<boolean>`
Returns true if the window is currently in fullscreen mode.

## Example

```typescript
import { browserWindow } from '@beacon-web-view/api';

// Toggle fullscreen
const isFS = await browserWindow.isFullscreen();
await browserWindow.setFullscreen(!isFS);

// Minimize after 5 seconds
setTimeout(() => {
  browserWindow.minimize();
}, 5000);
```
