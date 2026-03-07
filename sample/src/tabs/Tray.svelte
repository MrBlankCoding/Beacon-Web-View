<script>
  import { onMount } from "svelte";
  import { tray, shell, browserWindow } from "@beacon-web-view/api";
  import { log, logError } from "../consoleStore";

  let trayItems = [
    { id: "focus", title: "Focus App", key: "f" },
    { id: "refresh", title: "Refresh Stats", key: "r" },
    { isSeparator: true },
    { id: "quit", title: "Quit Beacon", key: "q" }
  ];

  async function handleTrayClick(id) {
    log(`Tray clicked: ${id}`);
    if (id === "quit") {
      await shell.exec("killall BeaconRuntime");
    } else if (id === "focus") {
      await browserWindow.focus();
    }
  }

  let unlisten = null;

  async function setupTray() {
    try {
      if (unlisten) unlisten();
      
      await tray.setIcon("gearshape.fill"); // Could implement api suuport for a custom icon
      await tray.setMenu(trayItems);
      unlisten = tray.onClick(handleTrayClick);
      log("Tray configured and listener attached");
    } catch (err) {
      logError(`Tray setup failed: ${err.message}`);
    }
  }

  onMount(() => {
    setupTray();
    return () => { if (unlisten) unlisten(); };
  });
</script>

<div class="card">
  <h2>Tray Management</h2>
  <p>Check your macOS menu bar for the Beacon icon.</p>
  <button on:click={setupTray}>Re-initialize Tray</button>
</div>
