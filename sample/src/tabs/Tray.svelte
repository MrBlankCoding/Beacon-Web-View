<script>
  import { onMount } from "svelte";
  import { tray, shell } from "@beacon-web-view/api";
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
      await shell.exec("killall Beacon");
    }
  }

  async function setupTray() {
    try {
      await tray.setIcon("gearshape.fill");
      await tray.setMenu(trayItems);
      tray.onClick(handleTrayClick);
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
