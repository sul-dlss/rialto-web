import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="check-login"
// tabs should have data-tab-name attribute to identify how to set the URL
export default class extends Controller {
  static values = {
    link: String
  }

  goImmediatelty() {
    clearTimeout(this.redirect);
    window.location.href = this.linkValue;
  }

  sessionTimeout() {
    if(document.querySelector('[data-logged-in="true"]')) return true;
    let params = new URLSearchParams(window.location.search);
    return params.get("session_timeout");
  }

  connect() {
    if (this.sessionTimeout()) {
      const myModalElement = document.getElementById('modal');
      const modal = new bootstrap.Modal(myModalElement);
      modal.show();
      const href = this.linkValue;
      this.redirect = setTimeout(function() {
        window.location.href = href;
      }, 5000);
    }
  }
}
