<script>
  import { browserWindow, app, theme } from "@beacon-web-view/api";
  import { log, logError } from "../consoleStore";

  let badgeText = "5";
  let currentTheme = "system";

  async function setBadge() {
    try {
      await app.setBadge(badgeText);
      log(`Dock badge set to: ${badgeText}`);
    } catch (err) {
      logError(`Failed to set badge: ${err.message}`);
    }
  }

  async function clearBadge() {
    try {
      await app.setBadge(null);
      log("Dock badge cleared");
    } catch (err) {
      logError(`Failed to clear badge: ${err.message}`);
    }
  }

  async function toggleFullscreen() {
    try {
      const isFS = await browserWindow.isFullscreen();
      await browserWindow.setFullscreen(!isFS);
      log(`Fullscreen toggled: ${!isFS}`);
    } catch (err) {
      logError(`Fullscreen toggle failed: ${err.message}`);
    }
  }

  async function minimize() {
    await browserWindow.minimize();
  }

  async function maximize() {
    await browserWindow.maximize();
  }

  async function setTheme(mode) {
    try {
      await theme.setTheme(mode);
      currentTheme = mode;
      log(`Theme override set to: ${mode}`);
    } catch (err) {
      logError(`Theme set failed: ${err.message}`);
    }
  }
</script>

<div class="grid">
  <div class="card">
    <h2>Window Controls</h2>
    <p>Manage the current application window state.</p>
    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
      <button on:click={toggleFullscreen}>Toggle Fullscreen</button>
      <div style="display: flex; gap: 0.5rem;">
        <button on:click={minimize} class="ghost" style="flex: 1;">Minimize</button>
        <button on:click={maximize} class="ghost" style="flex: 1;">Maximize</button>
      </div>
    </div>
  </div>

  <div class="card">
    <h2>Dock Badge</h2>
    <p>Set a red badge on the application Dock icon.</p>
    <div style="display: flex; gap: 0.5rem;">
      <input type="text" bind:value={badgeText} style="width: 80px;" placeholder="Label" />
      <button on:click={setBadge}>Set Badge</button>
      <button on:click={clearBadge} class="ghost">Clear</button>
    </div>
  </div>

  <div class="card">
    <h2>Theme Override</h2>
    <p>Force the application into a specific appearance mode.</p>
    <div style="display: flex; gap: 0.5rem; flex-wrap: wrap;">
      <button on:click={() => setTheme('light')} class={currentTheme === 'light' ? '' : 'ghost'}>Light</button>
      <button on:click={() => setTheme('dark')} class={currentTheme === 'dark' ? '' : 'ghost'}>Dark</button>
      <button on:click={() => setTheme('system')} class={currentTheme === 'system' ? '' : 'ghost'}>System</button>
    </div>
  </div>
</div>
