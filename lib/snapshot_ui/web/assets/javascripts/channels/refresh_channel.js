import consumer from "channels/consumer"
import * as Turbo from "@hotwired/turbo"

consumer.subscriptions.create("RefreshChannel", {
  connected() {
    console.log("Connected. Waiting for snapshots updates...")

    const connected_event = new CustomEvent("refresh-connected");
    window.dispatchEvent(connected_event);
  },

  disconnected() {
    console.log("Unsubscribed from snapshots updates. Trying to reconnect...")

    const disconnected_event = new CustomEvent("refresh-disconnected");
    window.dispatchEvent(disconnected_event);
  },

  received(_data) {
    console.log("Snapshots updated.")
    Turbo.visit(location, { action: "replace" })

    if (document.querySelector("iframe#raw")) {
      document.querySelector("iframe#raw").contentWindow.location.reload()
    }
  }
});
