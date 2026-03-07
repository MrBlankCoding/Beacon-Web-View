declare global {
  interface Window {
    __beacon_callbacks?: Map<string, Callback>;
    __beacon_nativeCallback?: (id: string, success: boolean, result: any) => void;
    __beacon_nativeCallbackBatch?: (batch: [string, boolean, any][]) => void;
    webkit?: {
      messageHandlers?: {
        native?: {
          postMessage: (message: any) => void;
        };
      };
    };
  }
}

type Callback = {
  resolve: (value: any) => void;
  reject: (reason?: any) => void;
};

const getCallbacks = (): Map<string, Callback> => {
  if (typeof window === 'undefined') return new Map();
  if (!window.__beacon_callbacks) {
    window.__beacon_callbacks = new Map();
  }
  return window.__beacon_callbacks;
};

let callIdCounter = Date.now();

const handleNativeCallback = (id: string, success: boolean, result: any) => {
  const callbacks = getCallbacks();
  const cb = callbacks.get(id);
  if (cb) {
    callbacks.delete(id);
    if (success) cb.resolve(result);
    else cb.reject(new Error(result));
  }
};

if (typeof window !== 'undefined') {
  window.__beacon_nativeCallback = handleNativeCallback;

  window.__beacon_nativeCallbackBatch = (batch) => {
    for (const [id, success, result] of batch) {
      handleNativeCallback(id, success, result);
    }
  };
}

function callNative<T = any>(command: string, args: Record<string, any> = {}): Promise<T> {
  return new Promise((resolve, reject) => {
    const id = (callIdCounter++).toString();
    getCallbacks().set(id, { resolve, reject });
    
    const messageHandler = window.webkit?.messageHandlers?.native;
    
    if (!messageHandler) {
      getCallbacks().delete(id);
      reject(new Error(
        'Beacon runtime not available. This code must run inside a Beacon application window. ' +
        '(window.webkit.messageHandlers.native is missing)'
      ));
      return;
    }

    try {
      messageHandler.postMessage({ id, command, args });
    } catch (err: any) {
      getCallbacks().delete(id);
      reject(new Error(`Failed to send message to Beacon: ${err.message}`));
    }
  });
}

type Listener = (data: any) => void;
const listeners = new Map<string, Set<Listener>>();

if (typeof window !== 'undefined') {
  const eventTypes = ['beacon-tray-click', 'beacon-shortcut', 'beacon-menu-click', 'beacon-theme-change'];
  eventTypes.forEach(type => {
    window.addEventListener(type, (e: any) => {
      const typeListeners = listeners.get(type);
      if (typeListeners) {
        typeListeners.forEach(l => l(e.detail));
      }
    });
  });

  // Console Hijacking for Native Debugging
  const originalConsole = {
    log: console.log,
    warn: console.warn,
    error: console.error,
    debug: console.debug,
  };

  const forwardLog = (level: string, args: any[]) => {
    const message = args.map(arg => {
      if (typeof arg === 'object') {
        try { return JSON.stringify(arg); } catch { return String(arg); }
      }
      return String(arg);
    }).join(' ');
    
    callNative('debug.log', { level, message });
  };

  console.log = (...args) => {
    originalConsole.log(...args);
    forwardLog('info', args);
  };
  console.warn = (...args) => {
    originalConsole.warn(...args);
    forwardLog('warn', args);
  };
  console.error = (...args) => {
    originalConsole.error(...args);
    forwardLog('error', args);
  };
  console.debug = (...args) => {
    originalConsole.debug(...args);
    forwardLog('debug', args);
  };

  // Window Draggable Regions Support
  window.addEventListener('mousedown', (e) => {
    let target = e.target as HTMLElement | null;
    while (target && target !== document.documentElement) {
      if (target.style && ((target.style as any).webkitAppRegion === 'drag' || target.hasAttribute('data-beacon-drag'))) {
        // Prevent drag on inputs/buttons/interactive elements
        const tagName = target.tagName.toLowerCase();
        if (tagName !== 'button' && tagName !== 'input' && tagName !== 'select' && tagName !== 'textarea') {
          callNative('window.startDragging');
        }
        break;
      }
      target = target.parentElement;
    }
  });
}

function on(event: string, listener: Listener) {
  if (!listeners.has(event)) {
    listeners.set(event, new Set());
  }
  listeners.get(event)!.add(listener);
  return () => off(event, listener);
}

function off(event: string, listener: Listener) {
  const typeListeners = listeners.get(event);
  if (typeListeners) {
    typeListeners.delete(listener);
  }
}

export const fs = {
  readFile: (path: string) => callNative<string>('fs.readFile', { path }),
  writeFile: (path: string, content: string) => callNative<void>('fs.writeFile', { path, content }),
  listDirectory: (path: string) => callNative<string[]>('fs.listDirectory', { path }),
  exists: (path: string) => callNative<boolean>('fs.exists', { path }),
  isDirectory: (path: string) => callNative<boolean>('fs.isDirectory', { path }),
};

export const dialog = {
  showOpenDialog: (options: any) => callNative<string[]>('dialog.showOpenDialog', options),
  showSaveDialog: (options: any) => callNative<string>('dialog.showSaveDialog', options),
};

export const clipboard = {
  readText: () => callNative<string>('clipboard.readText'),
  writeText: (text: string) => callNative<void>('clipboard.writeText', { text }),
};

export const notifications = {
  send: (title: string, body: string) => callNative<void>('notifications.send', { title, body }),
};

export const shell = {
  exec: (command: string) => callNative<string>('shell.exec', { command }),
};

export const menu = {
  showContextMenu: (items: any[]) => callNative<void>('menu.showContextMenu', { items }),
  onClick: (listener: (itemId: string) => void) => on('beacon-menu-click', listener),
};

export const system = {
  getStats: () => callNative<any>('system.getStats'),
  getMachineInfo: () => callNative<any>('system.getMachineInfo'),
  getStorageInfo: () => callNative<any>('system.getStorageInfo'),
};

export const tray = {
  setIcon: (image: string) => callNative<void>('tray.setIcon', { image }),
  setMenu: (items: any[]) => callNative<void>('tray.setMenu', { items }),
  destroy: () => callNative<void>('tray.destroy'),
  onClick: (listener: (data: any) => void) => on('beacon-tray-click', listener),
};

export const shortcuts = {
  register: (shortcut: string) => callNative<void>('shortcuts.register', { shortcut }),
  unregisterAll: () => callNative<void>('shortcuts.unregisterAll'),
  onTrigger: (listener: (shortcut: string) => void) => on('beacon-shortcut', listener),
};

export const browserWindow = {
  minimize: () => callNative<void>('window.minimize'),
  maximize: () => callNative<void>('window.maximize'),
  close: () => callNative<void>('window.close'),
  focus: () => callNative<void>('window.focus'),
  setFullscreen: (fullscreen: boolean) => callNative<void>('window.setFullscreen', { fullscreen }),
  isMaximized: () => callNative<boolean>('window.isMaximized'),
  isMinimized: () => callNative<boolean>('window.isMinimized'),
  isFullscreen: () => callNative<boolean>('window.isFullscreen'),
};

export const theme = {
  getTheme: () => callNative<'light' | 'dark'>('theme.getTheme'),
  setTheme: (theme: 'light' | 'dark' | 'system') => callNative<void>('theme.setTheme', { theme }),
  onThemeChange: (listener: (theme: 'light' | 'dark') => void) => on('beacon-theme-change', listener),
};

export const app = {
  getVersion: () => callNative<string>('app.getVersion'),
  getConfig: () => callNative<any>('app.getConfig'),
  openWindow: (url?: string) => callNative<void>('app.openWindow', { url }),
  setBadge: (label: string | null) => callNative<void>('app.setBadge', { label }),
};
