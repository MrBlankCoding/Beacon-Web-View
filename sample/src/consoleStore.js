import { writable } from 'svelte/store';

export const logs = writable([]);

export function log(message, type = 'info') {
    logs.update(l => [{
        id: Date.now(),
        timestamp: new Date().toLocaleTimeString(),
        message,
        type
    }, ...l].slice(0, 100));
}

export function logError(message) {
    log(message, 'error');
}
