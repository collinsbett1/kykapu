import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values = { expiresAt: String }

  connect() {
    this.tick()
    this.timer = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    const expiry = new Date(this.expiresAtValue).getTime()
    const now = Date.now()
    const remainingMs = expiry - now

    if (Number.isNaN(expiry) || remainingMs <= 0) {
      this.displayTarget.textContent = "Expired"
      clearInterval(this.timer)
      return
    }

    const totalSeconds = Math.floor(remainingMs / 1000)
    const hours = Math.floor(totalSeconds / 3600)
    const minutes = Math.floor((totalSeconds % 3600) / 60)
    const seconds = totalSeconds % 60
    this.displayTarget.textContent = `${this.pad(hours)}:${this.pad(minutes)}:${this.pad(seconds)}`
  }

  pad(value) {
    return value.toString().padStart(2, "0")
  }
}
