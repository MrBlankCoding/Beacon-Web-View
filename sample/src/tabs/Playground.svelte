<script>
  import { shell, notifications, dialog } from "@beacon-web-view/api";
  import { log, logError } from "../consoleStore";

  let command = "echo 'Hello from Beacon!'";
  let output = "";
  let isRunning = false;

  async function runCommand() {
    if (!command) return;
    isRunning = true;
    try {
      log(`Running shell command: ${command}`);
      output = await shell.exec(command);
      log("Command finished successfully");
    } catch (err) {
      logError(`Command failed: ${err.message}`);
      output = `Error: ${err.message}`;
    } finally {
      isRunning = false;
    }
  }

  async function sendTestNotification() {
    await notifications.send("Playground", "This is a test notification from the playground!");
  }

  async function openTestDialog() {
    const files = await dialog.showOpenDialog({
      title: "Select a file",
      message: "Choose any file to see its path",
      buttonLabel: "Select"
    });
    if (files && files.length > 0) {
      log(`User selected: ${files[0]}`);
    }
  }
</script>

<div class="grid">
  <div class="card" style="grid-column: span 2;">
    <h2>Native Playground</h2>
    <p>Enter a shell command and press play to execute it on your Mac.</p>
    
    <div style="display: flex; gap: 0.5rem; margin-top: 1rem;">
      <input 
        type="text" 
        bind:value={command} 
        placeholder="e.g., ls -la /Users" 
        style="flex: 1;"
        on:keydown={(e) => e.key === 'Enter' && runCommand()}
      />
      <button on:click={runCommand} disabled={isRunning}>
        {isRunning ? "Running..." : "▶ Play"}
      </button>
    </div>

    {#if output}
      <pre style="background: #121212; color: #00ff00; padding: 1rem; border-radius: 4px; margin-top: 1rem; overflow-x: auto; font-size: 0.8rem; border: 1px solid #333;">{output}</pre>
    {/if}
  </div>

  <div class="card">
    <h2>Native Utilities</h2>
    <div style="display: flex; flex-direction: column; gap: 0.5rem;">
      <button on:click={sendTestNotification} class="ghost">Send Notification</button>
      <button on:click={openTestDialog} class="ghost">Open File Dialog</button>
    </div>
  </div>
  
  <div class="card">
    <h2>Quick Links</h2>
    <p style="font-size: 0.9rem; color: #888;">Beacon allows you to bridge any macOS native API to your web view with minimal overhead.</p>
    <a href="https://github.com" target="_blank" style="color: #007aff; text-decoration: none; font-size: 0.9rem;">View Documentation →</a>
  </div>
</div>
