<script>
  import { logs, log } from "../consoleStore";

  function getLogColor(type) {
    switch (type) {
      case "error": return "#ff3b30";
      case "info": return "#007aff";
      default: return "#ffffff";
    }
  }

  async function copyLogs() {
    try {
      const text = $logs.map(l => `[${l.timestamp}] ${l.type.toUpperCase()}: ${l.message}`).join("\n");
      await window.beacon.clipboard.writeText(text);
      log("Logs copied to macOS clipboard");
    } catch (err) {
      console.error(err);
    }
  }

  async function copySelectedText() {
    const selection = window.getSelection().toString();
    if (selection) {
      await window.beacon.clipboard.writeText(selection);
      log("Selected text copied");
    }
  }

  async function handleContextMenu(e) {
    e.preventDefault();
    
    // Set global callback for this menu session
    window.onBeaconMenuClick = (id) => {
      if (id === 'copy-selection') copySelectedText();
      if (id === 'copy-all') copyLogs();
      if (id === 'clear') $logs = [];
    };

    const hasSelection = window.getSelection().toString().length > 0;

    await window.beacon.menu.showContextMenu([
      { id: 'copy-selection', label: 'Copy Selection', enabled: hasSelection },
      { isSeparator: true },
      { id: 'copy-all', label: 'Copy All Logs' },
      { id: 'clear', label: 'Clear Console' }
    ]);
  }
</script>

<div class="card">
  <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 0.5rem;">
    <h2>System Console</h2>
    <div style="display: flex; gap: 0.5rem;">
      <button on:click={copyLogs}>Copy Logs</button>
      <button class="ghost" on:click={() => $logs = []}>Clear</button>
    </div>
  </div>
  <div 
    style="background: #121212; border-radius: 8px; overflow: hidden; border: 1px solid #333;"
    on:contextmenu={handleContextMenu}
  >
    <div style="height: 400px; overflow-y: auto; padding: 1rem; font-family: 'SF Mono', 'Monaco', monospace; font-size: 0.85rem; user-select: text;">
      {#each $logs as entry (entry.id)}
        <div style="margin-bottom: 0.5rem; display: flex; gap: 1rem;">
          <span style="color: #666; flex-shrink: 0; user-select: none;">[{entry.timestamp}]</span>
          <span style="color: {getLogColor(entry.type)}; flex-shrink: 0; user-select: none;">{entry.type.toUpperCase()}</span>
          <span style="word-break: break-all;">{entry.message}</span>
        </div>
      {/each}
      {#if $logs.length === 0}
        <div style="color: #666; text-align: center; padding: 2rem; user-select: none;">No system logs available.</div>
      {/if}
    </div>
  </div>
  <p style="font-size: 0.7rem; color: #666; margin-top: 0.5rem;">Right-click for native console options. Text selection enabled.</p>
</div>
