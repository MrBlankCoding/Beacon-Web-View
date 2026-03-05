# Menu API (`menu`)

Show native context menus at the current mouse location.

## Usage

```typescript
import { menu } from '@beacon-web-view/api';
```

## Permissions

No permission required.

## Methods

### `showContextMenu(items: MenuItem[]): Promise<void>`
Shows a popup menu.

`MenuItem` fields:

- `id?: string`
- `label?: string`
- `enabled?: boolean` (default `true`)
- `isSeparator?: boolean`
- `submenu?: MenuItem[]`

### `onClick(listener: (itemId: string) => void): () => void`
Register a listener for menu item clicks. Returns an unregister function.

## Example

```typescript
import { menu } from '@beacon-web-view/api';

const unregister = menu.onClick((id) => {
  if (id === "copy") {
    console.log("copy clicked");
  }
});

await menu.showContextMenu([
  { id: "copy", label: "Copy" },
  { id: "paste", label: "Paste", enabled: false },
  { isSeparator: true },
  {
    label: "Share",
    submenu: [
      { id: "email", label: "Email" },
      { id: "messages", label: "Messages" }
    ]
  }
]);
```
