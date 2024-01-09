import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autocomplete"
export default class extends Controller {
  connect() {
    console.log("autocomplete")
  }
  initialize(){
    let inputs = document.getElementById("horaires").querySelectorAll("input");

    ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"].forEach((element)=>{
      let datas = JSON.parse(this.data.get("horaires"));
      //let inputId = `institut_horaires_${element}_am_1`;
      document.getElementById(`institut_horaires_${element}_am_1`).value = datas[element].am_1
    })

      //debugger;
      //document.getElementById(`institut_horaires_${element}_am_1`).value = datas.day.am_1

  }
}
