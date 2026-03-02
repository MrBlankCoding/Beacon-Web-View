<script>
  import { onMount } from "svelte";
  import { logError } from "../consoleStore";

  let storage = {
    totalGB: 0,
    availableGB: 0,
    usedGB: 0,
    usedPercent: 0,
    freePercent: 0
  };
  let isLoading = true;

  async function refreshStorage() {
    if (!window.beacon?.system?.getStorageInfo) {
      logError("System API unavailable: getStorageInfo is missing");
      return;
    }
    try {
      storage = await window.beacon.system.getStorageInfo();
    } catch (err) {
      logError(`Storage info failed: ${err.message}`);
    } finally {
      isLoading = false;
    }
  }

  onMount(() => {
    refreshStorage();
    const interval = setInterval(refreshStorage, 30000);
    return () => clearInterval(interval);
  });
</script>

<div class="card">
  <h2>System Storage</h2>
  
  {#if isLoading}
    <p>Loading storage information...</p>
  {:else}
    <div style="margin-bottom: 2rem;">
      <div class="stat-row">
        <span>Used Space</span>
        <span>{storage.usedPercent.toFixed(1)}%</span>
      </div>
      <div class="progress-bar">
        <div class="progress-fill" style="width: {storage.usedPercent}%"></div>
      </div>
      <p style="font-size: 0.8rem; color: #888; margin-top: 0.5rem;">
        {storage.usedGB.toFixed(2)} GB used of {storage.totalGB.toFixed(2)} GB
      </p>
    </div>

    <div class="grid" style="grid-template-columns: 1fr 1fr; gap: 1rem;">
      <div style="background: rgba(255,255,255,0.05); padding: 1rem; border-radius: 8px;">
        <p style="font-size: 0.7rem; color: #888; margin-bottom: 0.2rem; text-transform: uppercase;">Available</p>
        <p style="font-size: 1.2rem; font-weight: bold; color: #34c759;">{storage.availableGB.toFixed(2)} GB</p>
        <p style="font-size: 0.8rem; color: #666;">{storage.freePercent.toFixed(1)}% free</p>
      </div>
      <div style="background: rgba(255,255,255,0.05); padding: 1rem; border-radius: 8px;">
        <p style="font-size: 0.7rem; color: #888; margin-bottom: 0.2rem; text-transform: uppercase;">Total Capacity</p>
        <p style="font-size: 1.2rem; font-weight: bold;">{storage.totalGB.toFixed(2)} GB</p>
        <p style="font-size: 0.8rem; color: #666;">APFS Volume</p>
      </div>
    </div>

    <button on:click={refreshStorage} style="margin-top: 1.5rem;">Refresh Now</button>
  {/if}
</div>
