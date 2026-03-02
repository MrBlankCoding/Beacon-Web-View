# Tray API (`window.beacon.tray`)

Create and manage a macOS status bar (menu bar) item.

## Permissions

No permission required.

## Methods

### `setIcon(image?: string): Promise<string>`
Sets tray icon and resolves with `"ok"`.

`image` can be:

- SF Symbol name (for example `"gearshape.fill"`)
- image path
- omitted/null to fall back to text title

### `setMenu(items: TrayMenuItem[]): Promise<string>`
Sets tray menu and resolves with `"ok"`.

`TrayMenuItem` fields:

- `id?: string`
- `title?: string`
- `key?: string`
- `isSeparator?: boolean`

### `destroy(): Promise<string>`
Removes the tray item and resolves with `"ok"`.

## Events

When a tray item is clicked, Beacon emits:

- DOM event `beacon-tray-click` (`event.detail` is the item id)
- callback `window.onBeaconTrayClick(id)`

## Example

```js
window.onBeaconTrayClick = (id) => {
  if (id === "quit") {
    console.log("quit clicked");
  }
};

await window.beacon.tray.setIcon("gearshape.fill");
await window.beacon.tray.setMenu([
  { id: "show", title: "Show App", key: "s" },
  { isSeparator: true },
  { id: "quit", title: "Quit", key: "q" }
]);
```
