# Shortcuts API (`shortcuts`)

Register global/local keyboard shortcuts and receive events when they fire.

## Usage

```typescript
import { shortcuts } from '@beacon-web-view/api';
```

## Permissions

No permission required.

## Methods

### `register(shortcut: string): Promise<void>`
Registers a shortcut.

Format:

- `modifier+modifier+key`
- modifiers: `command` (`cmd`), `shift`, `control` (`ctrl`), `option` (`alt`)
- example: `command+shift+b`

### `unregisterAll(): Promise<void>`
Removes all registered shortcuts.

### `onTrigger(listener: (combo: string) => void): () => void`
Register a listener for shortcut triggers. Returns an unregister function.

## Example

```typescript
import { shortcuts } from '@beacon-web-view/api';

const unregister = shortcuts.onTrigger((combo) => {
  console.log("shortcut:", combo);
});

await shortcuts.register("command+shift+b");
```
