import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.display_status()
  }

  connected(_event) {
    window.refresh_status = "connected"
    this.display_status()
  }

  disconnected(_event) {
    window.refresh_status = undefined
    this.display_status()
  }

  display_status() {
    if (window.refresh_status === "connected") {
      document.title = "Snapshot UI - ✅ Connected"
    } else {
      document.title = "Snapshot UI - ⏳ Reconnecting..."
    }
  }
}
