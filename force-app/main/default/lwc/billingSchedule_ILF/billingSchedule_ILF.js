/* eslint-disable no-console */
/**
 * @File Name          : billingSchedule_ILF.js
 * @Description        :
 * @Author             : venu.navuluri@finastra.com
 * @Group              :
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 06/02/2020, 12:30:00
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    22/01/2020   venu.navuluri@finastra.com     Initial Version
 **/
import { LightningElement, wire, api, track } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "lightning/uiRecordApi";
import { getRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import billingScheduleHelpTest from "@salesforce/label/c.Billing_Schedule_Help_Test";
import Billing_Schedule_ILF_Error from "@salesforce/label/c.Billing_Schedule_ILF_Error";
import License_Schedule from "@salesforce/label/c.License_Schedule";
import Generate_License_Schedules from "@salesforce/label/c.Generate_License_Schedules";
import License_Billing_Schedule from "@salesforce/label/c.License_Billing_Schedule";
import Billing_Term from "@salesforce/label/c.Billing_Term";
import Add_row from "@salesforce/label/c.Add_row";
import Select from "@salesforce/label/c.Select";

// APEX class Methods
import getILFStandardTerms from "@salesforce/apex/billingScheduleController.getILFStandardTerms";
import getExistingILFStandardTerms from "@salesforce/apex/billingScheduleController.getExistingILFStandardTerms";
import generateBillingScheduleItems from "@salesforce/apex/billingScheduleController.generateBillingScheduleItems";

//  Object and field API Name  //
import SBQQ_QUOTE_OBJECT from "@salesforce/schema/SBQQ__Quote__c";
import BILLING_SCHEDULE_OBJECT from "@salesforce/schema/Billing_Schedule__c";
import LICENCE_TERMS from "@salesforce/schema/SBQQ__Quote__c.License_Billing_Terms__c";
import BILLING_TERM from "@salesforce/schema/Billing_Schedule__c.Billing_Term__c";

const cols = [
  {
    label: "Billing Milestone Name",
    fieldName: "Name",
    editable: false,
    required: true
  },
  {
    label: "Percentage(%)",
    fieldName: "Percentage__c",
    type: "number",
    cellAttributes: { alignment: "left" },
    editable: false
  }
];
const FIELDS = [LICENCE_TERMS];

export default class BillingSchedule_ILF extends NavigationMixin(
  LightningElement
) {
  label = {
    billingScheduleHelpTest,
    Billing_Schedule_ILF_Error,
    Generate_License_Schedules,
    License_Billing_Schedule,
    License_Schedule,
    Billing_Term,
    Select,
    Add_row
  };

  @api recordId;
  @api bsId;
  @api selectedLicenseSchedule = "Standard";
  @api objectApiName;
  // license table variables
  @api licenseData = [];
  @api existingLicenseData = [];
  @track quote;
  @track columns = cols;
  @track draftValues = [];
  @track showLicenseButtons = false;
  @track generateSchedule = true;
  @track schedulesExisted = false;
  @track showCheckboxColumn = false;
  @track showBillingTerm = true;
  @track selectedBillingTerm = "Billing Term - 1";
  @track BILLING_SCHEDULE_SUCCESS = "Billing Schedule Created Successfully!!";
  @track BILLING_SCHEDULE_PERCENTAGE_VALIDATION =
    "Total percentage should be 100%";
  @track BILLING_SCHEDULE_ROW_VALIDATION =
    "Please insert all data for each row.";

  @wire(getObjectInfo, { objectApiName: SBQQ_QUOTE_OBJECT })
  quoteInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$quoteInfo.data.defaultRecordTypeId",
    fieldApiName: LICENCE_TERMS
  })
  LicenseTermPicklistValues;

  @wire(getObjectInfo, { objectApiName: BILLING_SCHEDULE_OBJECT })
  billingScheduleInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$billingScheduleInfo.data.defaultRecordTypeId",
    fieldApiName: BILLING_TERM
  })
  BillingTermPicklistValues;

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredRecord({ data }) {
    if (data) {
      this.quote = data;
      if (this.quote.fields.License_Billing_Terms__c.value != null) {
        this.selectedLicenseSchedule = this.quote.fields.License_Billing_Terms__c.value;
        this.generateSchedule = false;
        this.schedulesExisted = true;
        this.selectedBillingTerm = "";
      }
    }
  }

  licenseScheduleChange(event) {
    this.selectedLicenseSchedule = event.detail.value;
    this.selectedBillingTerm = "";
    if (
      event.detail.value === "Standard" ||
      event.detail.value === "Non Standard"
    ) {
      this.showLicenseButtons = false;
      this.showBillingTerm = true;
    }
    if (event.detail.value === "Custom") {
      this.licenseData = [];
      this.showLicenseButtons = true;
      this.showBillingTerm = false;
      this.showCheckboxColumn = true;
      this.generateSchedule = false;
    }

    this.columns = [
      {
        label: "Billing Milestone Name",
        fieldName: "Name",
        editable: this.selectedLicenseSchedule === "Custom" ? true : false
      },
      {
        label: "Percentage(%)",
        fieldName: "Percentage__c",
        type: "number",
        cellAttributes: { alignment: "left" },
        editable:
          this.selectedLicenseSchedule === "Custom" ||
          this.selectedLicenseSchedule === "Non Standard"
            ? true
            : false
      }
    ];
  }
  billingTermChange(event) {
    this.value = event.detail.value;
    this.selectedBillingTerm = event.target.value;
  }
  @wire(getExistingILFStandardTerms, { quoteId: "$recordId" })
  getExistingILFStandardTerms({ data, error }) {
    if (data) {
      this.existingLicenseData = data;
    } else if (error) {
      window.console.error(error);
    }
  }

  @wire(getILFStandardTerms, { billingTerm: "$selectedBillingTerm" })
  getILFStandardTerms({ data, error }) {
    if (data) {
      let stdItems = [];
      data.forEach(row => {
        stdItems.push({
          Name: row.Milestone_Name__c,
          Percentage__c: row.Percentage__c
        });
      });
      this.licenseData = stdItems;
    } else if (error) {
      window.console.error(error);
    }
  }

  addLicenseRow() {
    let customSchedule = [...this.licenseData];
    customSchedule.push({
      Name: "",
      Percentage__c: ""
    });
    this.licenseData = customSchedule;
  }

  handleSaveEdition(event) {
    let consolidatedRows = [...this.licenseData];
    const tempValues = event.detail.draftValues;
    let hasError = false;
    tempValues.forEach(row => {
      console.log({ row });
      const index = row.Id.slice(4);

      if (row.Name === undefined) {
        row.Name = consolidatedRows[index].Name;
      }
      if (
        row.Name.length > 0 &&
        (row.Percentage__c > 0 || consolidatedRows[index].Percentage__c > 0)
      ) {
        consolidatedRows[index].Name = row.Name;
        if (row.Percentage__c > 0) {
          consolidatedRows[index].Percentage__c = row.Percentage__c;
        }
      } else {
        this.dispatchEvent(
          new ShowToastEvent({
            message: this.BILLING_SCHEDULE_ROW_VALIDATION,
            variant: "error"
          })
        );
        hasError = true;
      }
    });
    if (!hasError) {
      const reducer = (accumlator, num) => {
        return accumlator + num;
      };
      //   consolidatedRows = validRows;
      const percentageSum = consolidatedRows
        .map(x => Number(x.Percentage__c))
        .reduce(reducer, 0);
      if (percentageSum === 100.0) {
        this.draftValues = [];
        this.licenseData = consolidatedRows.filter(
          row => row.Name !== "" && row.Percentage__c !== ""
        );
        this.generateSchedule = true;
      } else {
        this.dispatchEvent(
          new ShowToastEvent({
            message: this.BILLING_SCHEDULE_PERCENTAGE_VALIDATION,
            variant: "error"
          })
        );
      }
    } else {
      this.licenseData = consolidatedRows;
    }
  }

  handleSave() {
    // Creating the object that represents the shape
    // of the Apex wrapper class.
    let parameterObject = {
      Name: "",
      percentage: 100,
      itemList: []
    };
    // Populating a list
    for (let i = 0; i < this.licenseData.length; i++) {
      const element = this.licenseData[i];
      parameterObject.itemList.push({
        Name: element.Name,
        percentage: element.Percentage__c
      });
    }

    generateBillingScheduleItems({
      wrapper: parameterObject,
      quoteId: this.recordId,
      billingTerm: this.selectedBillingTerm,
      selectedLicenseSchedule: this.selectedLicenseSchedule
    }).then(result => {
      if (result.includes("Error at")) {
        this.error = result;
        this.dispatchEvent(
          new ShowToastEvent({
            message: result,
            variant: "error"
          })
        );
      } else {
        this.bsId = result;
        this.dispatchEvent(
          new ShowToastEvent({
            message: this.BILLING_SCHEDULE_SUCCESS,
            variant: "success"
          })
        );
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: this.bsId,
            actionName: "view"
          }
        });
        refreshApex(this.wiredRecord);
      }
    });
  }
}
