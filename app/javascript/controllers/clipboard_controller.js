import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "toast"]

  async copy() {
    const text = this.sourceTarget.value

    try {
      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(text)
      } else {
        this.sourceTarget.focus()
        this.sourceTarget.select()
        document.execCommand("copy")
      }
      this.showToast("Invite link copied")
    } catch (error) {
      this.showToast("Copy failed, select and copy manually")
    }
  }

  showToast(message) {
    this.toastTarget.textContent = message
    this.toastTarget.classList.add("is-visible")
    clearTimeout(this.toastTimer)
    this.toastTimer = setTimeout(() => {
      this.toastTarget.classList.remove("is-visible")
    }, 1800)
  }
}
