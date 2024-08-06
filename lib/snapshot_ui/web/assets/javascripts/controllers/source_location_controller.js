import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  copy(event) {
    event.preventDefault()

    if (window.isSecureContext) {
      let currentTarget = event.currentTarget

      navigator.clipboard.writeText(currentTarget.dataset.sourceLocation)

      currentTarget.classList.toggle('animate');
      setTimeout(()=> {
        currentTarget.classList.toggle('animate')
      },300)
    } else {
      let message =
        `Copying to the clipboard isn't possible in an insecure browser context.\n\n` +
        `You are accessing this page from a hostname ${window.location.hostname} which is considered insecure.\n\n` +
        `Changing the hostname will most likely resolve the issue.`

      alert(message)
    }
  }
}
