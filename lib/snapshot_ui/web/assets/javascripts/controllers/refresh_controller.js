import { Controller } from "@hotwired/stimulus"
import * as Turbo from "@hotwired/turbo"

// Keeps the page in sync with the published snapshots.
//
// Every page is rendered with the version of the published snapshots it shows
// (`data-refresh-version-value` on <body>). This controller polls the version
// endpoint and, as soon as the version changes, refreshes the page through
// Turbo, which morphs the new content in and preserves the scroll position.
// The tab title shows whether polling is working.
export default class extends Controller {
  static values = {
    url: String,
    version: String,
    interval: { type: Number, default: 1000 }
  }

  connect() {
    this.online = false
    this.displayStatus()
    this.timer = setInterval(() => this.check(), this.intervalValue)
    this.check()
  }

  disconnect() {
    clearInterval(this.timer)
  }

  // Called by Stimulus once the refreshed page, carrying the new version, has
  // been rendered. Polling then continues with that version.
  versionValueChanged() {
    this.refreshing = false
  }

  // Polling pauses while the tab is hidden, so catch up as soon as it is visible
  // again (wired to `visibilitychange`).
  async check() {
    if (this.checking || this.refreshing || document.hidden || this.previewing) return
    this.checking = true

    try {
      const response = await fetch(this.urlValue, {
        cache: "no-store",
        headers: { "If-None-Match": `"${this.versionValue}"` }
      })

      if (response.status === 304) {
        this.setOnline(true)
      } else if (response.ok) {
        this.setOnline(true)
        if ((await response.text()) !== this.versionValue) this.refresh()
      } else {
        this.setOnline(false)
      }
    } catch (_error) {
      this.setOnline(false)
    } finally {
      this.checking = false
    }
  }

  refresh() {
    this.refreshing = true
    // Should the refresh not go through (e.g. the app went away half-way), resume polling after a while.
    setTimeout(() => { this.refreshing = false }, 10 * this.intervalValue)

    Turbo.visit(location.href, { action: "replace" })
    // Morphing keeps the iframe as it is, so reload the snapshot it shows explicitly.
    document.querySelector("iframe#raw")?.contentWindow.location.reload()
  }

  setOnline(online) {
    if (this.online === online) return

    this.online = online
    this.displayStatus()
  }

  // Turbo resets the title whenever it renders a page, so this also runs on `turbo:render`.
  displayStatus() {
    const title = document.title.replace(/ - (✅|⏳).*$/, "")
    document.title = `${title} - ${this.online ? "✅ Connected" : "⏳ Reconnecting..."}`
  }

  // Turbo may show a cached copy of a page while loading it; leave that alone.
  get previewing() {
    return document.documentElement.hasAttribute("data-turbo-preview")
  }
}
