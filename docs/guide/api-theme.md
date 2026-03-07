# Theme API (`theme`)

Detection and control of the system appearance (Light vs Dark mode).

## Usage

```typescript
import { theme } from '@beacon-web-view/api';
```

## Permissions

No permission required.

## Methods

### `getTheme(): Promise<'light' | 'dark'>`
Returns the current effective system theme.

### `setTheme(theme: 'light' | 'dark' | 'system'): Promise<void>`
Overrides the application theme. Use `'system'` to revert to the system-wide setting.

### `onThemeChange(listener: (theme: 'light' | 'dark') => void): () => void`
Registers a listener that fires when the system or application theme changes. Returns an unregister function.

## Example

```typescript
import { theme } from '@beacon-web-view/api';

// Get current theme
const current = await theme.getTheme();
console.log(`Initial theme: ${current}`);

// Listen for changes
const unlisten = theme.onThemeChange((newTheme) => {
  console.log(`Theme changed to: ${newTheme}`);
  updateAppColors(newTheme);
});

// Force dark mode
await theme.setTheme('dark');

// Revert to system default
await theme.setTheme('system');

// Clean up listener
unlisten();
```
