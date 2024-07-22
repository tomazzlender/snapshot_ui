import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  copy(event) {
    event.preventDefault()

    let currentTarget = event.currentTarget

    navigator.clipboard.writeText(currentTarget.dataset.sourceLocation)

    currentTarget.classList.toggle('animate');
    setTimeout(()=> {
      currentTarget.classList.toggle('animate')
    },300)

  }
}
