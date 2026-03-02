# System API (`window.beacon.system`)

Read machine metadata and resource utilization.

## Permissions

No permission required.

## Methods

### `getStats(): Promise<{ cpu: number, memory: number, disk: number }>`
Returns:

- `cpu`: CPU usage percentage (current implementation is approximate)
- `memory`: memory usage percentage
- `disk`: startup disk usage percentage

### `getMachineInfo(): Promise<object>`
Returns:

- `model`: hardware model identifier
- `osVersion`: macOS version string
- `uptime`: formatted uptime string
- `processorCount`: active CPU core count

### `getStorageInfo()`

Returns detailed storage metrics for the startup volume.

- `totalGB`: total capacity in gigabytes
- `availableGB`: free space in gigabytes
- `usedGB`: used space in gigabytes
- `usedPercent`: percentage of disk used
- `freePercent`: percentage of disk free

## Example

```js
const stats = await window.beacon.system.getStats();
console.log(`CPU ${stats.cpu}% | MEM ${stats.memory}% | DISK ${stats.disk}%`);

const info = await window.beacon.system.getMachineInfo();
console.log(info.model, info.osVersion, info.uptime);

const storage = await window.beacon.system.getStorageInfo();
console.log(`Free space: ${storage.availableGB.toFixed(2)} GB (${storage.freePercent.toFixed(1)}%)`);
```
