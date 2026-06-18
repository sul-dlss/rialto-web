import { Controller } from "@hotwired/stimulus"

// Stabilizes Tableau sizing when embeds load via lazy turbo-frames in Bootstrap tabs.
export default class extends Controller {
  connect() {
    this.handleFrameLoad = this.handleFrameLoad.bind(this)
    this.handleTabShown = this.handleTabShown.bind(this)

    this.element.addEventListener("turbo:frame-load", this.handleFrameLoad)
    document.addEventListener("shown.bs.tab", this.handleTabShown)

    this.queueResize()
  }

  disconnect() {
    this.element.removeEventListener("turbo:frame-load", this.handleFrameLoad)
    document.removeEventListener("shown.bs.tab", this.handleTabShown)
  }

  handleFrameLoad(event) {
    const frame = event.target
    if (!(frame instanceof HTMLElement)) return

    const pane = frame.closest(".tab-pane")
    if (this.isActivePane(pane)) {
      this.queueResize(pane)
    }
  }

  handleTabShown(event) {
    const tabTrigger = event.target
    if (!(tabTrigger instanceof HTMLElement)) return

    const selector = tabTrigger.getAttribute("data-bs-target")
    if (!selector) return

    const pane = document.querySelector(selector)
    if (pane instanceof HTMLElement) {
      this.queueResize(pane)
    }
  }

  queueResize(pane = null) {
    const delays = [0, 100, 300]

    delays.forEach((delay) => {
      window.setTimeout(() => {
        this.resizeVizInPane(pane)
      }, delay)
    })
  }

  resizeVizInPane(pane = null) {
    const targetPane = pane || this.activePane()
    if (!(targetPane instanceof HTMLElement)) return

    const viz = targetPane.querySelector("tableau-viz")
    if (!(viz instanceof HTMLElement)) return

    const parent = viz.parentElement
    if (!(parent instanceof HTMLElement)) return

    const parentWidth = parent.clientWidth
    if (!parentWidth) return

    viz.style.display = "block"
    viz.style.width = "100%"
    viz.style.maxWidth = "100%"

    const vizWidth = viz.getBoundingClientRect().width
    if (vizWidth && vizWidth < parentWidth * 0.9) {
      viz.style.width = `${parentWidth}px`
      requestAnimationFrame(() => {
        viz.style.width = "100%"
        window.dispatchEvent(new Event("resize"))
      })
      return
    }

    window.dispatchEvent(new Event("resize"))
  }

  activePane() {
    return this.element.parentElement?.querySelector(".tab-pane.show.active") || null
  }

  isActivePane(pane) {
    return pane instanceof HTMLElement && pane.classList.contains("show") && pane.classList.contains("active")
  }
}
