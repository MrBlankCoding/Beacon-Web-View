<script>
  import { onMount } from "svelte";
  import { log, logError } from "../consoleStore";

  let lastShortcut = "None";

  async function setupShortcuts() {
    if (!window.beacon?.shortcuts?.register) {
      logError("Shortcuts API unavailable: window.beacon.shortcuts.register is missing");
      return;
    }
    try {
      await window.beacon.shortcuts.register("command+shift+b");
      window.onBeaconShortcut = (combo) => {
        lastShortcut = combo;
        log(`Shortcut triggered: ${combo}`);
      };
      log("Shortcut registered: command+shift+b");
    } catch (err) {
      logError(`Shortcuts setup failed: ${err.message}`);
    }
  }

  onMount(() => {
    setupShortcuts();
  });
</script>

<div class="card">
  <h2>Global Shortcuts</h2>
  <div style="background: #121212; padding: 2rem; border-radius: 8px; text-align: center; margin-bottom: 1rem;">
    <p style="font-size: 0.8rem; color: #888; margin-bottom: 0.5rem;">LAST TRIGGERED</p>
    <p style="font-size: 1.5rem; font-family: monospace; color: #007aff;">{lastShortcut}</p>
  </div>
  <p>Try pressing <code>⌘ + ⇧ + B</code> anywhere on your system.</p>
</div>
