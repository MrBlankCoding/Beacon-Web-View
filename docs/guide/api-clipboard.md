# Clipboard API (`clipboard`)

Read and write plaintext to the system clipboard.

## Usage

```typescript
import { clipboard } from '@beacon-web-view/api';
```

## Permissions

No permission required.

## Methods

### `readText(): Promise<string>`
Returns the current clipboard text. If clipboard has no text, returns an empty string.

### `writeText(text: string): Promise<void>`
Writes plaintext to the clipboard.

## Example

```typescript
import { clipboard } from '@beacon-web-view/api';

await clipboard.writeText("Copied from Beacon");
const text = await clipboard.readText();
console.log(text);
```
