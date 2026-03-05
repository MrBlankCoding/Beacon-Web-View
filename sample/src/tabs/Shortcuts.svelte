<script>
  import { onMount } from "svelte";
  import { shortcuts } from "@beacon-web-view/api";
  import { log, logError } from "../consoleStore";

  let lastShortcut = "None";

  async function setupShortcuts() {
    try {
      await shortcuts.register("command+shift+b");
      shortcuts.onTrigger((combo) => {
        lastShortcut = combo;
        log(`Shortcut triggered: ${combo}`);
      });
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
