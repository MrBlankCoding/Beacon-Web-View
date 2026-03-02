# Dialog API (`window.beacon.dialog`)

Open native macOS file and save dialogs.

## Permissions

No permission key is required.

Selected paths are bookmarked internally so scoped filesystem access can persist across launches.

## Methods

### `showOpenDialog(options): Promise<string | string[]>`
Shows an `NSOpenPanel`.

`options`:

- `canChooseDirectories` (boolean, default `true`)
- `canChooseFiles` (boolean, default `true`)
- `allowsMultipleSelection` (boolean, default `false`)
- `message` (string)
- `buttonLabel` (string)

Returns:

- single-select: selected path string
- multi-select: array of selected path strings

### `showSaveDialog(options): Promise<string>`
Shows an `NSSavePanel`.

`options`:

- `message` (string)
- `buttonLabel` (string)
- `defaultName` (string)

Returns selected save path.

## Example

```js
const folder = await window.beacon.dialog.showOpenDialog({
  canChooseDirectories: true,
  canChooseFiles: false,
  message: "Select export folder"
});

const outputPath = await window.beacon.dialog.showSaveDialog({
  defaultName: "report.txt",
  buttonLabel: "Save"
});
```
