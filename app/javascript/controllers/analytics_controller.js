import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="analytics"
export default class extends Controller {
  static values = { fileName: String, dashboard: String }

  trackDownload() {
    if (typeof gtag === 'undefined') return
    gtag('event', 'file_download', { file_name: this.fileNameValue })
  }

  trackVisualization(event) {
    if (typeof gtag === 'undefined') return
    gtag('event', 'view_visualization', {
      dashboard: this.dashboardValue,
      tab: event.currentTarget.dataset.tabName
    })
  }

  trackLogin() {
    if (typeof gtag === 'undefined') return
    gtag('event', 'login', { method: 'Shibboleth' })
  }
}
