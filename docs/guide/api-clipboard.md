# Clipboard API (`window.beacon.clipboard`)

Read and write plaintext to the system clipboard.

## Permissions

No permission required.

## Methods

### `readText(): Promise<string>`
Returns the current clipboard text. If clipboard has no text, returns an empty string.

### `writeText(text: string): Promise<string>`
Writes plaintext to the clipboard and resolves with `"ok"`.

## Example

```js
await window.beacon.clipboard.writeText("Copied from Beacon");
const text = await window.beacon.clipboard.readText();
console.log(text);
```
