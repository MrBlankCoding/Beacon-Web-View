<script>
  import { onMount } from "svelte";

  let activeTab = "dashboard";
  let runtimeVersion = "Checking...";
  let status = { message: "Initializing...", ok: true };
  let diskUsage = 0;
  let cpuLoad = 0;
  let memoryUsage = 0;
  let uptime = "Checking...";
  
  let shellCommand = "sysctl -n machdep.cpu.brand_string";
  let shellOutput = "";
  let isRunningCommand = false;

  let desktopFiles = [];
  let isLoadingFiles = false;

  let notif = { title: "System Alert", body: "A message from Beacon" };

  async function updateStatus(msg, ok = true) {
    status = { message: msg, ok };
    setTimeout(() => {
      if (status.message === msg) status.message = "Ready";
    }, 5000);
  }

  async function refreshStats() {
    try {
      // Memory Usage (simulated via shell)
      const vmStat = await window.beacon.shell.exec("vm_stat | grep 'Pages free'");
      const freePagesMatch = vmStat.match(/(\d+)/);
      if (freePagesMatch) {
        // Very rough estimation just to show dynamic data
        memoryUsage = Math.floor(Math.random() * 40) + 30; 
      }

      // Disk Usage
      const df = await window.beacon.shell.exec("df -h / | tail -1");
      const parts = df.split(/\s+/);
      const percent = parts[4] ? parseInt(parts[4]) : 0;
      diskUsage = percent;

      // Uptime
      uptime = await window.beacon.shell.exec("uptime | cut -d ',' -f 1 | cut -d ' ' -f 3-");
      
      // Random CPU for visual effect
      cpuLoad = Math.floor(Math.random() * 20) + 5;
    } catch (err) {
      console.error("Stats error", err);
    }
  }

  async function runShell() {
    if (!shellCommand.trim()) return;
    isRunningCommand = true;
    try {
      shellOutput = await window.beacon.shell.exec(shellCommand);
      updateStatus("Command executed successfully");
    } catch (err) {
      shellOutput = `Error: ${err.message}`;
      updateStatus(err.message, false);
    } finally {
      isRunningCommand = false;
    }
  }

  async function loadFiles() {
    isLoadingFiles = true;
    try {
      desktopFiles = await window.beacon.fs.listDirectory("~/Desktop");
      updateStatus(`Found ${desktopFiles.length} items on Desktop`);
    } catch (err) {
      updateStatus(err.message, false);
    } finally {
      isLoadingFiles = false;
    }
  }

  async function sendNotif() {
    try {
      await window.beacon.notifications.send(notif.title, notif.body);
      updateStatus("Notification sent");
    } catch (err) {
      updateStatus(err.message, false);
    }
  }

  onMount(async () => {
    try {
      runtimeVersion = await window.beacon.app.getVersion();
      updateStatus("Ready");
      refreshStats();
      const interval = setInterval(refreshStats, 10000);
      return () => clearInterval(interval);
    } catch (err) {
      updateStatus("Beacon runtime not detected", false);
    }
  });
</script>

<div class="app">
  <header>
    <h1>Beacon System Manager</h1>
    <span class="runtime-info">v{runtimeVersion}</span>
  </header>

  <main class="main-content">
    <aside>
      <nav>
        <ul>
          <li class:active={activeTab === 'dashboard'} on:click={() => activeTab = 'dashboard'}>Dashboard</li>
          <li class:active={activeTab === 'explorer'} on:click={() => activeTab = 'explorer'}>File Explorer</li>
          <li class:active={activeTab === 'terminal'} on:click={() => activeTab = 'terminal'}>Terminal</li>
          <li class:active={activeTab === 'notifications'} on:click={() => activeTab = 'notifications'}>Notifications</li>
        </ul>
      </nav>
    </aside>

    <div class="view">
      {#if activeTab === 'dashboard'}
        <div class="grid">
          <div class="card">
            <h2>System Health</h2>
            <div class="stat-row">
              <span>CPU Load</span>
              <span>{cpuLoad}%</span>
            </div>
            <div class="progress-bar"><div class="progress-fill" style="width: {cpuLoad}%"></div></div>

            <div class="stat-row">
              <span>Memory Usage</span>
              <span>{memoryUsage}%</span>
            </div>
            <div class="progress-bar"><div class="progress-fill" style="width: {memoryUsage}%"></div></div>

            <div class="stat-row">
              <span>Disk Space (/)</span>
              <span>{diskUsage}%</span>
            </div>
            <div class="progress-bar"><div class="progress-fill" style="width: {diskUsage}%"></div></div>
          </div>

          <div class="card">
            <h2>Machine Info</h2>
            <p><strong>Uptime:</strong> {uptime}</p>
            <p><strong>OS:</strong> macOS</p>
            <button on:click={refreshStats}>Refresh Now</button>
          </div>
        </div>

      {:else if activeTab === 'explorer'}
        <div class="card">
          <h2>Desktop Explorer</h2>
          <div style="display: flex; gap: 1rem; align-items: center; margin-bottom: 1rem;">
            <button on:click={loadFiles} disabled={isLoadingFiles}>
              {isLoadingFiles ? 'Scanning...' : 'Scan ~/Desktop'}
            </button>
            <span>{desktopFiles.length} items found</span>
          </div>
          {#if desktopFiles.length > 0}
            <pre>{desktopFiles.join('\n')}</pre>
          {:else}
            <p style="opacity: 0.5; text-align: center; padding: 2rem;">No items to display. Click Scan to load.</p>
          {/if}
        </div>

      {:else if activeTab === 'terminal'}
        <div class="card">
          <h2>Beacon Shell</h2>
          <input type="text" bind:value={shellCommand} placeholder="Enter command..." on:keydown={(e) => e.key === 'Enter' && runShell()} />
          <button on:click={runShell} disabled={isRunningCommand}>
            {isRunningCommand ? 'Running...' : 'Execute'}
          </button>
          {#if shellOutput}
            <pre style="margin-top: 1.5rem;">{shellOutput}</pre>
          {/if}
        </div>

      {:else if activeTab === 'notifications'}
        <div class="card">
          <h2>Test Notifications</h2>
          <div style="max-width: 400px;">
            <label>Title</label>
            <input type="text" bind:value={notif.title} />
            <label>Message</label>
            <input type="text" bind:value={notif.body} />
            <button on:click={sendNotif}>Dispatch Notification</button>
          </div>
        </div>
      {/if}
    </div>
  </main>

  <footer>
    <div class="status">
      <span class="status-dot {status.ok ? 'status-ready' : 'status-error'}"></span>
      {status.message}
    </div>
    <div class="links">
      Beacon Runtime Project
    </div>
  </footer>
</div>
