# Menu API (`window.beacon.menu`)

Show native context menus at the current mouse location.

## Permissions

No permission required.

## Methods

### `showContextMenu(items: MenuItem[]): Promise<string>`
Shows a popup menu and resolves with `"ok"`.

`MenuItem` fields:

- `id?: string`
- `label?: string`
- `enabled?: boolean` (default `true`)
- `isSeparator?: boolean`
- `submenu?: MenuItem[]`

## Events

When a user clicks an item with `id`, Beacon emits:

- DOM event `beacon-menu-click` (`event.detail` is the id)
- callback `window.onBeaconMenuClick(id)`

## Example

```js
window.onBeaconMenuClick = (id) => {
  if (id === "copy") {
    console.log("copy clicked");
  }
};

await window.beacon.menu.showContextMenu([
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
