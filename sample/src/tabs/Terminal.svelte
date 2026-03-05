<script>
  import { shell } from "@beacon-web-view/api";
  import { log, logError } from "../consoleStore";

  let shellCommand = "sysctl -n machdep.cpu.brand_string";
  let shellOutput = "";
  let isRunningCommand = false;

  async function runShell() {
    if (!shellCommand.trim()) return;
    isRunningCommand = true;
    try {
      shellOutput = await shell.exec(shellCommand);
      log(`Shell command: ${shellCommand}`);
    } catch (err) {
      shellOutput = `Error: ${err.message}`;
      logError(`Shell failed: ${err.message}`);
    } finally {
      isRunningCommand = false;
    }
  }
</script>

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
