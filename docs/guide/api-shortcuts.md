# Shortcuts API (`window.beacon.shortcuts`)

Register global/local keyboard shortcuts and receive events when they fire.

## Permissions

No permission required.

## Methods

### `register(shortcut: string): Promise<string>`
Registers a shortcut and resolves with `"ok"`.

Format:

- `modifier+modifier+key`
- modifiers: `command` (`cmd`), `shift`, `control` (`ctrl`), `option` (`alt`)
- example: `command+shift+b`

### `unregisterAll(): Promise<string>`
Removes all registered shortcuts and resolves with `"ok"`.

## Events

When a registered shortcut is pressed, Beacon emits:

- DOM event `beacon-shortcut` (`event.detail` is normalized combo string)
- callback `window.onBeaconShortcut(combo)`

## Example

```js
window.onBeaconShortcut = (combo) => {
  console.log("shortcut:", combo);
};

await window.beacon.shortcuts.register("command+shift+b");
```
