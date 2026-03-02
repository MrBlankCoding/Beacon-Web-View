# Shell API (`window.beacon.shell`)

Execute shell commands through `/bin/zsh -lc`.

## Permissions

Requires `permissions.shell: true`.

## Methods

### `exec(command: string): Promise<string>`
Runs the command and returns combined `stdout` + `stderr`.

Behavior:

- exit code `0`: resolves with output (or `"(no output)"`)
- non-zero exit code: rejects with command output/error message

## Example

```js
const output = await window.beacon.shell.exec("df -h /");
console.log(output);
```
