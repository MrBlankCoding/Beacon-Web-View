(function() {
    "use strict";

    const pending = new Map();
    let callId = 0;

    function invoke(command, args) {
        return new Promise(function(resolve, reject) {
            const id = String(++callId);
            pending.set(id, { resolve: resolve, reject: reject });
            window.webkit.messageHandlers.native.postMessage({
                id: id,
                command: command,
                args: args || {}
            });
        });
    }

    window.__beacon_nativeCallback = function(id, ok, payload) {
        const entry = pending.get(String(id));
        if (!entry) return;

        pending.delete(String(id));
        if (ok) {
            entry.resolve(payload);
        } else {
            const message = typeof payload === "string" ? payload : "Unknown error";
            entry.reject(new Error(message));
        }
    };

    window.__beacon_nativeCallbackBatch = function(batch) {
        if (!Array.isArray(batch)) return;
        for (let i = 0; i < batch.length; i += 1) {
            const item = batch[i];
            if (!Array.isArray(item) || item.length < 3) continue;
            window.__beacon_nativeCallback(item[0], item[1], item[2]);
        }
    };

    window.beacon = {
        fs: {
            readFile: function(path) {
                return invoke("fs.readFile", { path: path });
            },
            writeFile: function(path, content) {
                return invoke("fs.writeFile", { path: path, content: content });
            },
            listDirectory: function(path) {
                return invoke("fs.listDirectory", { path: path });
            },
            exists: function(path) {
                return invoke("fs.exists", { path: path });
            }
        },
        notifications: {
            send: function(title, body) {
                return invoke("notifications.send", { title: title, body: body });
            }
        },
        shell: {
            exec: function(command) {
                return invoke("shell.exec", { command: command });
            }
        },
        app: {
            getConfig: function() {
                return invoke("app.getConfig", {});
            },
            getVersion: function() {
                return invoke("app.getVersion", {});
            }
        }
    };

    Object.freeze(window.beacon.fs);
    Object.freeze(window.beacon.notifications);
    Object.freeze(window.beacon.shell);
    Object.freeze(window.beacon.app);
    Object.freeze(window.beacon);
})();
