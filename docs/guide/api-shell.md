# Shell API (`shell`)

Execute shell commands through `/bin/zsh -lc`.

## Usage

```typescript
import { shell } from '@beacon-web-view/api';
```

## Permissions

Requires `permissions.shell: true`.

## Methods

### `exec(command: string): Promise<string>`
Runs the command and returns combined `stdout` + `stderr`.

Behavior:

- exit code `0`: resolves with output (or `"(no output)"`)
- non-zero exit code: rejects with command output/error message

## Example

```typescript
import { shell } from '@beacon-web-view/api';

const output = await shell.exec("df -h /");
console.log(output);
```
