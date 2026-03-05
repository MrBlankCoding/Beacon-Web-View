# Dialog API (`dialog`)

Open native macOS file and save dialogs.

## Usage

```typescript
import { dialog } from '@beacon-web-view/api';
```

## Permissions

No permission key is required.

Selected paths are bookmarked internally so scoped filesystem access can persist across launches.

## Methods

### `showOpenDialog(options): Promise<string[]>`
Shows an `NSOpenPanel`.

`options`:

- `canChooseDirectories` (boolean, default `true`)
- `canChooseFiles` (boolean, default `true`)
- `allowsMultipleSelection` (boolean, default `false`)
- `message` (string)
- `buttonLabel` (string)

Returns an array of selected path strings.

### `showSaveDialog(options): Promise<string>`
Shows an `NSSavePanel`.

`options`:

- `message` (string)
- `buttonLabel` (string)
- `defaultName` (string)

Returns selected save path.

## Example

```typescript
import { dialog } from '@beacon-web-view/api';

const paths = await dialog.showOpenDialog({
  canChooseDirectories: true,
  canChooseFiles: false,
  message: "Select export folder"
});

const outputPath = await dialog.showSaveDialog({
  defaultName: "report.txt",
  buttonLabel: "Save"
});
```
