# Tray API (`tray`)

Create and manage a macOS status bar (menu bar) item.

## Usage

```typescript
import { tray } from '@beacon-web-view/api';
```

## Permissions

No permission required.

## Methods

### `setIcon(image?: string): Promise<void>`
Sets tray icon.

`image` can be:

- SF Symbol name (for example `"gearshape.fill"`)
- image path
- omitted/null to fall back to text title

### `setMenu(items: TrayMenuItem[]): Promise<void>`
Sets tray menu.

`TrayMenuItem` fields:

- `id?: string`
- `title?: string`
- `key?: string`
- `isSeparator?: boolean`

### `destroy(): Promise<void>`
Removes the tray item.

### `onClick(listener: (itemId: string) => void): () => void`
Register a listener for tray item clicks. Returns an unregister function.

## Example

```typescript
import { tray } from '@beacon-web-view/api';

const unregister = tray.onClick((id) => {
  if (id === "quit") {
    console.log("quit clicked");
  }
});

await tray.setIcon("gearshape.fill");
await tray.setMenu([
  { id: "show", title: "Show App", key: "s" },
  { isSeparator: true },
  { id: "quit", title: "Quit", key: "q" }
]);
```
