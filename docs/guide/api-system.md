# System API (`system`)

Read machine metadata and resource utilization.

## Usage

```typescript
import { system } from '@beacon-web-view/api';
```

## Permissions

No permission required.

## Methods

### `getStats(): Promise<{ cpu: number, memory: number, disk: number }>`
Returns:

- `cpu`: CPU usage percentage
- `memory`: memory usage percentage
- `disk`: startup disk usage percentage

### `getMachineInfo(): Promise<object>`
Returns:

- `model`: hardware model identifier
- `osVersion`: macOS version string
- `uptime`: formatted uptime string
- `processorCount`: active CPU core count

### `getStorageInfo(): Promise<object>`
Returns detailed storage metrics for the startup volume.

- `totalGB`: total capacity in gigabytes
- `availableGB`: free space in gigabytes
- `usedGB`: used space in gigabytes
- `usedPercent`: percentage of disk used
- `freePercent`: percentage of disk free

## Example

```typescript
import { system } from '@beacon-web-view/api';

const stats = await system.getStats();
console.log(`CPU ${stats.cpu}% | MEM ${stats.memory}% | DISK ${stats.disk}%`);

const info = await system.getMachineInfo();
console.log(info.model, info.osVersion, info.uptime);

const storage = await system.getStorageInfo();
console.log(`Free space: ${storage.availableGB.toFixed(2)} GB (${storage.freePercent.toFixed(1)}%)`);
```
