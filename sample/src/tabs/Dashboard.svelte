<script>
  import { onMount } from "svelte";
  import { system } from "@beacon-web-view/api";
  import { logError } from "../consoleStore";

  let diskUsage = 0;
  let cpuLoad = 0;
  let memoryUsage = 0;
  let uptime = "Checking...";
  let model = "Detecting...";
  let osVersion = "...";

  async function refreshStats() {
    try {
      const stats = await system.getStats();
      cpuLoad = Math.round(stats.cpu);
      memoryUsage = Math.round(stats.memory);
      diskUsage = Math.round(stats.disk);
    } catch (err) {
      logError(`System stats failed: ${err.message}`);
    }
  }

  async function loadMachineInfo() {
    try {
      const info = await system.getMachineInfo();
      model = info.model;
      osVersion = info.osVersion;
      uptime = info.uptime;
    } catch (err) {
      logError(`Machine info failed: ${err.message}`);
    }
  }

  onMount(() => {
    loadMachineInfo();
    refreshStats();
    const statsInterval = setInterval(refreshStats, 3000);
    const infoInterval = setInterval(loadMachineInfo, 60000); // Uptime and model don't change often
    return () => {
        clearInterval(statsInterval);
        clearInterval(infoInterval);
    };
  });
</script>

<div class="grid">
  <div class="card">
    <h2>Real-time Resources</h2>
    <div class="stat-row">
      <span>CPU Usage</span>
      <span>{cpuLoad}%</span>
    </div>
    <div class="progress-bar"><div class="progress-fill" style="width: {cpuLoad}%"></div></div>

    <div class="stat-row">
      <span>Physical Memory</span>
      <span>{memoryUsage}%</span>
    </div>
    <div class="progress-bar"><div class="progress-fill" style="width: {memoryUsage}%"></div></div>

    <div class="stat-row">
      <span>Startup Disk</span>
      <span>{diskUsage}%</span>
    </div>
    <div class="progress-bar"><div class="progress-fill" style="width: {diskUsage}%"></div></div>
  </div>

  <div class="card">
    <h2>Machine Hardware</h2>
    <p><strong>Model:</strong> {model}</p>
    <p><strong>macOS:</strong> {osVersion}</p>
    <p><strong>Uptime:</strong> {uptime}</p>
    <button on:click={() => { refreshStats(); loadMachineInfo(); }}>Refresh Now</button>
  </div>
</div>
