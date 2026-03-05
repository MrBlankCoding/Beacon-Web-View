<script>
  import { clipboard } from "@beacon-web-view/api";
  import { log, logError } from "../consoleStore";

  let clipboardText = "";

  async function copyToClipboard() {
    try {
      if (!clipboardText) return;
      await clipboard.writeText(clipboardText);
      log("Copied to macOS clipboard");
    } catch (err) {
      logError(`Copy failed: ${err.message}`);
    }
  }

  async function pasteFromClipboard() {
    try {
      clipboardText = await clipboard.readText();
      log("Pasted from macOS clipboard");
    } catch (err) {
      logError(`Paste failed: ${err.message}`);
    }
  }
</script>

<div class="card">
  <h2>Clipboard Bridge</h2>
  <div style="max-width: 500px;">
    <label>Text to Copy/Paste</label>
    <input type="text" bind:value={clipboardText} placeholder="Enter text..." />
    <div style="display: flex; gap: 1rem;">
      <button on:click={copyToClipboard}>Copy to macOS</button>
      <button on:click={pasteFromClipboard} class="ghost">Paste from macOS</button>
    </div>
  </div>
</div>
