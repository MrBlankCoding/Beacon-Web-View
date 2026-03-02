(function() {
    if (window.beacon) return;

    const callbacks = new Map();
    let callIdCounter = 0;

    // Internal callback handler
    window.__beacon_nativeCallback = function(id, success, result) {
        const cb = callbacks.get(id);
        if (cb) {
            callbacks.delete(id);
            if (success) cb.resolve(result);
            else cb.reject(new Error(result));
        }
    };

    // Batch callback handler for performance
    window.__beacon_nativeCallbackBatch = function(batch) {
        for (let i = 0; i < batch.length; i++) {
            const [id, success, result] = batch[i];
            window.__beacon_nativeCallback(id, success, result);
        }
    };

    function callNative(command, args = {}) {
        return new Promise((resolve, reject) => {
            const id = (callIdCounter++).toString();
            callbacks.set(id, { resolve, reject });
            window.webkit.messageHandlers.native.postMessage({ id, command, args });
        });
    }

    window.beacon = {
        fs: {
            readFile: (path) => callNative('fs.readFile', { path }),
            writeFile: (path, content) => callNative('fs.writeFile', { path, content }),
            listDirectory: (path) => callNative('fs.listDirectory', { path }),
            exists: (path) => callNative('fs.exists', { path }),
            isDirectory: (path) => callNative('fs.isDirectory', { path }),
        },
        dialog: {
            showOpenDialog: (options) => callNative('dialog.showOpenDialog', options),
            showSaveDialog: (options) => callNative('dialog.showSaveDialog', options),
        },
        clipboard: {
            readText: () => callNative('clipboard.readText'),
            writeText: (text) => callNative('clipboard.writeText', { text }),
        },
        notifications: {
            send: (title, body) => callNative('notifications.send', { title, body }),
        },
        shell: {
            exec: (command) => callNative('shell.exec', { command }),
        },
        menu: {
            showContextMenu: (items) => callNative('menu.showContextMenu', { items }),
        },
        system: {
            getStats: () => callNative('system.getStats'),
            getMachineInfo: () => callNative('system.getMachineInfo'),
            getStorageInfo: () => callNative('system.getStorageInfo'),
        },
        tray: {
            setIcon: (image) => callNative('tray.setIcon', { image }),
            setMenu: (items) => callNative('tray.setMenu', { items }),
            destroy: () => callNative('tray.destroy'),
        },
        shortcuts: {
            register: (shortcut) => callNative('shortcuts.register', { shortcut }),
            unregisterAll: () => callNative('shortcuts.unregisterAll'),
        },
        app: {
            getVersion: () => callNative('app.getVersion'),
            getConfig: () => callNative('app.getConfig'),
            openWindow: () => callNative('app.openWindow'),
        }
    };

    // Initialize global event listeners for Beacon events
    window.addEventListener('beacon-tray-click', (e) => {
        if (window.onBeaconTrayClick) window.onBeaconTrayClick(e.detail);
    });
    window.addEventListener('beacon-shortcut', (e) => {
        if (window.onBeaconShortcut) window.onBeaconShortcut(e.detail);
    });
    window.addEventListener('beacon-menu-click', (e) => {
        if (window.onBeaconMenuClick) window.onBeaconMenuClick(e.detail);
    });
})();
