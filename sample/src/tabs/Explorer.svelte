<script>
  import { log, logError } from "../consoleStore";

  let desktopFiles = [];
  let isLoadingFiles = false;

  async function loadFiles() {
    isLoadingFiles = true;
    try {
      desktopFiles = await window.beacon.fs.listDirectory("~/Desktop");
      log(`Found ${desktopFiles.length} items on Desktop`);
    } catch (err) {
      logError(`Scan failed: ${err.message}`);
    } finally {
      isLoadingFiles = false;
    }
  }

  async function requestAccess() {
    try {
      const path = await window.beacon.dialog.showOpenDialog({
        canChooseDirectories: true,
        canChooseFiles: false,
        message: "Choose a folder to scan with Beacon"
      });
      log(`Granted access to: ${path}`);
      desktopFiles = await window.beacon.fs.listDirectory(path);
    } catch (err) {
      logError(`Access request failed: ${err.message}`);
    }
  }
</script>

<div class="card">
  <h2>Desktop Explorer</h2>
  <div style="display: flex; gap: 1rem; align-items: center; margin-bottom: 1rem; flex-wrap: wrap;">
    <button on:click={loadFiles} disabled={isLoadingFiles}>
      {isLoadingFiles ? 'Scanning...' : 'Scan ~/Desktop'}
    </button>
    <button on:click={requestAccess}>
      Request Folder Access
    </button>
    <span>{desktopFiles.length} items found</span>
  </div>
{#if desktopFiles.length > 0}
  <pre>{desktopFiles.join('\n')}</pre>
{:else}
    <p style="opacity: 0.5; text-align: center; padding: 2rem;">No items to display. Click Scan or Request Access.</p>
  {/if}
</div>
