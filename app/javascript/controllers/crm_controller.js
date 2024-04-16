import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="crm"
export default class extends Controller {
  static targets = ["form"]
  connect() {
  }

  send(event){
    event.preventDefault()
    console.log("TODO: send request in AJAX 2")

    fetch(this.formTarget.action, {
      method: "POST",
      headers: { "Accept": "application/json" },
      body: new FormData(this.formTarget)
    })
      .then(response => response.json())
      .then((data) => {
        if (data.inserted_item) {
          // beforeend could also be dynamic with Stimulus values

          //this.itemsTarget.querySelector("ul").remove()
          //this.itemsTarget.insertAdjacentHTML("beforeend", data.inserted_item)
        }
        //this.formTarget.outerHTML = data.form
      })
  }
}
