({
    
    getObsItems : function(component, helper) {
        var action = component.get("c.getLicenseItems");
        action.setParams({"quoteId": component.get('v.recordId')})
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.obsItems", response.getReturnValue());
                if(response.getReturnValue().length == 0) {
                    document.getElementById('license-payment').classList.add('slds-hide');
                }
            }
            
            else {
                console.error(response.getError());
            }
            $A.util.toggleClass(component.find("spinner"), "slds-hide");
        }));
        $A.enqueueAction(action);
    },
    
    getQuote: function(component, helper){
        var action = component.get("c.getQuote");
        action.setParams({"quoteId": component.get('v.recordId')})
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.quote", response.getReturnValue());
                component.set("v.selectedValue", component.get('v.quote').License_Payment_Terms__c);
                if(component.get('v.quote').License_Payment_Terms__c == 'Non - Standard'){
                    component.set('v.isNonStandard', true);
                }
                var cols = [
                    {label: 'Milestone Name', fieldName: 'Name', type: 'text', editable: component.get('v.isNonStandard')},
                    {label: 'Percentage %', fieldName: 'Line__c', type: 'number', editable: component.get('v.isNonStandard')},
                    {label: 'Amount', fieldName: 'Line_Amount__c', type: 'currency', editable: component.get('v.isNonStandard')},
                    {label: 'Drop Dead Date', fieldName: 'Line_Drop_Dead_Date__c', type: 'date-local', editable: true}
                ];
                component.set("v.tableCols", cols);
                helper.getObsItems(component, helper);
                this.getObsItems(component, helper);
            }
            else {
                console.error(response.getError());
            }
            $A.util.toggleClass(component.find("spinner"), "slds-hide");
        }));
        $A.enqueueAction(action);
    },
    
    addNewRow : function(component, helper) {
        var itemList = component.get("v.obsItems");
        itemList.push({
            'sobjectType': 'Opportunity_Billing_Schedule_Item__c',
            'Name': '',
            'Line__c':'',
            'Line_Amount__c': '',
            'Line_Drop_Dead_Date__c': '',
            'Line_Estimated_Completion_Date__c': ''
        });
        component.set("v.obsItems", itemList);
    },
    
})