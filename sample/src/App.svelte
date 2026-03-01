<script>
  let count = 0;
  let runtimeMeta = "Loading runtime info...";
  let statusMessage = "Ready.";
  let notifTitle = "Hello from Beacon";
  let notifBody = "This is a notification from your sample app.";
  let shellCommand = "pwd";
  let shellOutput = "No command run yet.";
  let desktopOutput = "Click to load ~/Desktop.";

  function setStatus(message) {
    statusMessage = `[${new Date().toLocaleTimeString()}] ${message}`;
  }

  async function loadRuntimeMeta() {
    try {
      const version = await window.beacon.app.getVersion();
      const config = await window.beacon.app.getConfig();
      const perms = config.permissions;

      runtimeMeta = `Runtime ${version} | FS: ${perms.filesystem ? "on" : "off"} | Notif: ${perms.notifications ? "on" : "off"} | Shell: ${perms.shell ? "on" : "off"}`;
      setStatus("Runtime ready.");
    } catch (error) {
      runtimeMeta = "Runtime info unavailable";
      setStatus(`Runtime info failed: ${error.message}`);
    }
  }

  async function sendNotification() {
    const title = notifTitle.trim();
    const body = notifBody.trim();
    if (!title) {
      setStatus("Notification title is required.");
      return;
    }

    try {
      await window.beacon.notifications.send(title, body);
      setStatus(`Notification sent: "${title}"`);
    } catch (error) {
      setStatus(`Notification failed: ${error.message}`);
    }
  }

  async function runShellCommand() {
    const command = shellCommand.trim();
    if (!command) {
      setStatus("Shell command is required.");
      return;
    }

    shellOutput = "Running...";
    try {
      const result = await window.beacon.shell.exec(command);
      shellOutput = result || "(no output)";
      setStatus(`Shell command completed: ${command}`);
    } catch (error) {
      shellOutput = `Error: ${error.message}`;
      setStatus(`Shell command failed: ${error.message}`);
    }
  }

  async function listDesktopFiles() {
    desktopOutput = "Loading...";
    try {
      const entries = await window.beacon.fs.listDirectory("~/Desktop");
      if (!entries || entries.length === 0) {
        desktopOutput = "(Desktop is empty)";
      } else {
        desktopOutput = entries.join("\n");
      }
      setStatus(`Loaded ${entries.length} Desktop entries.`);
    } catch (error) {
      desktopOutput = `Error: ${error.message}`;
      setStatus(`Listing Desktop failed: ${error.message}`);
    }
  }

  loadRuntimeMeta();
</script>

<main class="app">
  <header>
    <h1>Beacon Svelte Sample</h1>
    <p>{runtimeMeta}</p>
  </header>

  <section class="card">
    <h2>Counter</h2>
    <div class="counter">
      <button type="button" on:click={() => count -= 1}>-</button>
      <strong>{count}</strong>
      <button type="button" on:click={() => count += 1}>+</button>
      <button type="button" class="ghost" on:click={() => count = 0}>Reset</button>
    </div>
  </section>

  <section class="card">
    <h2>Notifications</h2>
    <label for="notif-title">Title</label>
    <input id="notif-title" type="text" bind:value={notifTitle} />
    <label for="notif-body">Body</label>
    <input id="notif-body" type="text" bind:value={notifBody} />
    <div class="row">
      <button type="button" on:click={sendNotification}>Send Notification</button>
    </div>
  </section>

  <section class="card">
    <h2>Shell Command</h2>
    <label for="shell-command">Command</label>
    <input id="shell-command" type="text" bind:value={shellCommand} />
    <div class="row">
      <button type="button" on:click={runShellCommand}>Run Command</button>
    </div>
    <pre>{shellOutput}</pre>
  </section>

  <section class="card">
    <h2>Desktop Files</h2>
    <div class="row">
      <button type="button" on:click={listDesktopFiles}>List Desktop Files</button>
    </div>
    <pre>{desktopOutput}</pre>
  </section>

  <section class="card">
    <h2>Status</h2>
    <pre>{statusMessage}</pre>
  </section>
</main>
