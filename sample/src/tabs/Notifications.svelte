<script>
  import { log, logError } from "../consoleStore";

  let notif = { title: "System Alert", body: "A message from Beacon" };

  async function sendNotif() {
    try {
      await window.beacon.notifications.send(notif.title, notif.body);
      log(`Notification sent: ${notif.title}`);
    } catch (err) {
      logError(`Notification failed: ${err.message}`);
    }
  }
</script>

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
