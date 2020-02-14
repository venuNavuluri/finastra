import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// importing Custom Label
import notificationMessage from "@salesforce/label/c.Lead_Conversion_Request_Notification";

export default class ToastMessage extends LightningElement {
  connectedCallback() {
    const toastEvnt = new ShowToastEvent({
      title: "",
      message: notificationMessage,
      variant: "success",
      mode: "dismissable"
    });
    this.dispatchEvent(toastEvnt);
  }
}
