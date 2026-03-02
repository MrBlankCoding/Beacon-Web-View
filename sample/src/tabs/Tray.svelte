<script>
  import { onMount } from "svelte";
  import { log, logError } from "../consoleStore";

  let trayItems = [
    { id: "show", title: "Show App", key: "s" },
    { id: "refresh", title: "Refresh Stats", key: "r" },
    { isSeparator: true },
    { id: "quit", title: "Quit Beacon", key: "q" }
  ];

  async function handleTrayClick(id) {
    log(`Tray clicked: ${id}`);
    if (id === "quit") {
      if (!window.beacon?.shell?.exec) {
        logError("Shell API unavailable: cannot quit from tray action");
        return;
      }
      await window.beacon.shell.exec("killall Beacon");
    }
  }

  async function setupTray() {
    if (!window.beacon?.tray?.setIcon || !window.beacon?.tray?.setMenu) {
      logError("Tray API unavailable: window.beacon.tray methods are missing");
      return;
    }
    try {
      await window.beacon.tray.setIcon("gearshape.fill");
      await window.beacon.tray.setMenu(trayItems);
      window.onBeaconTrayClick = handleTrayClick;
      log("Tray configured");
    } catch (err) {
      logError(`Tray setup failed: ${err.message}`);
    }
  }

  onMount(() => {
    setupTray();
  });
</script>

<div class="card">
  <h2>Tray Management</h2>
  <p>Check your macOS menu bar for the Beacon icon.</p>
  <button on:click={setupTray}>Re-initialize Tray</button>
</div>
