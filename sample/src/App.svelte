<script>
  import { onMount } from "svelte";
  import Dashboard from "./tabs/Dashboard.svelte";
  import Explorer from "./tabs/Explorer.svelte";
  import Terminal from "./tabs/Terminal.svelte";
  import Notifications from "./tabs/Notifications.svelte";
  import Clipboard from "./tabs/Clipboard.svelte";
  import Tray from "./tabs/Tray.svelte";
  import Shortcuts from "./tabs/Shortcuts.svelte";
  import Storage from "./tabs/Storage.svelte";
  import Console from "./tabs/Console.svelte";
  import { log, logError } from "./consoleStore";
  import { app as beaconApp } from "@beacon-web-view/api";

  let activeTab = "dashboard";
  let runtimeVersion = "Checking...";
  let isRuntimeDetected = false;
  let isCheckingRuntime = true;

  onMount(async () => {
    try {
      runtimeVersion = await beaconApp.getVersion();
      isRuntimeDetected = true;
      log("Beacon runtime initialized");
    } catch (err) {
      isRuntimeDetected = false;
      logError("Beacon runtime not detected. Native APIs will be unavailable.");
    } finally {
      isCheckingRuntime = false;
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
          <li class:active={activeTab === 'explorer'} on:click={() => activeTab = 'explorer'}>Filesystem</li>
          <li class:active={activeTab === 'terminal'} on:click={() => activeTab = 'terminal'}>Terminal</li>
          <li class:active={activeTab === 'notifications'} on:click={() => activeTab = 'notifications'}>Notifications</li>
          <li class:active={activeTab === 'clipboard'} on:click={() => activeTab = 'clipboard'}>Clipboard</li>
          <li class:active={activeTab === 'tray'} on:click={() => activeTab = 'tray'}>Tray</li>
          <li class:active={activeTab === 'shortcuts'} on:click={() => activeTab = 'shortcuts'}>Shortcuts</li>
          <li class:active={activeTab === 'storage'} on:click={() => activeTab = 'storage'}>Storage</li>
          <li class:active={activeTab === 'console'} on:click={() => activeTab = 'console'}>Console</li>
        </ul>
      </nav>
    </aside>

    <div class="view">
      {#if isCheckingRuntime}
        <div class="card" style="text-align: center; padding: 3rem;">
          <p>Connecting to Beacon Runtime...</p>
        </div>
      {:else if !isRuntimeDetected}
        <div class="card" style="border-color: #ff3b30; background: rgba(255, 59, 48, 0.1);">
          <p style="color: #ff3b30; font-weight: bold; margin: 0;">Runtime Not Detected</p>
          <p style="font-size: 0.9rem; margin-top: 0.5rem;">Please run this application within the Beacon Web View runtime to access native features.</p>
        </div>
      {:else}
        {#if activeTab === 'dashboard'}
          <Dashboard {runtimeVersion} />
        {:else if activeTab === 'explorer'}
          <Explorer />
        {:else if activeTab === 'terminal'}
          <Terminal />
        {:else if activeTab === 'notifications'}
          <Notifications />
        {:else if activeTab === 'clipboard'}
          <Clipboard />
        {:else if activeTab === 'tray'}
          <Tray />
        {:else if activeTab === 'shortcuts'}
          <Shortcuts />
        {:else if activeTab === 'storage'}
          <Storage />
        {:else if activeTab === 'console'}
          <Console />
        {/if}
      {/if}
    </div>
  </main>

  <footer>
    <div class="status">
      <span class="status-dot {isRuntimeDetected ? 'status-ready' : 'status-error'}"></span>
      {isRuntimeDetected ? 'Connected' : 'Disconnected'}
    </div>
    <div class="links">
      Beacon Runtime Project
    </div>
  </footer>
</div>
