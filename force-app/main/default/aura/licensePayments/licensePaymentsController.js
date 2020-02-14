({
    doInit : function(component, event, helper) {
        helper.getQuote(component, helper);
    },
    
    handleSaveEdition: function (component, event, helper) {
        //$A.util.toggleClass(component.find("spinner"), "slds-hide");
        var obsList = component.get("v.obsItems");
        var draftValues = event.getParam("draftValues");
        var total = 0.00; var tempVal = 0.00;
        for(var i = 0.00; i < obsList.length; i++){
            if(!isNaN(obsList[i].Line__c)){
                tempVal = parseFloat(obsList[i].Line__c);
            }
            for(var j = 0.00; j < draftValues.length; j++){
                if(draftValues[j].Id == obsList[i].Id && !isNaN(draftValues[j].Line__c)){
                    tempVal = parseFloat(draftValues[j].Line__c);
                }
            }
            if(tempVal > 0.00) total += tempVal;
        }
        tempVal = 0.00;
        for(var j = 0.00; j < draftValues.length; j++){
            if(draftValues[j].Id.length < 15 && !isNaN(draftValues[j].Line__c)){
                tempVal += parseFloat(draftValues[j].Line__c);
            }
        }
        
        total += tempVal;
        if( total == 100.00){
            component.set('v.errors', null);
            var action = component.get("c.saveOBSItems");
            action.setParams({"itemsList" : draftValues, 
                              "obsId" : obsList[0].Opportunity_Billing_Schedule__c,
                              "quoteId" : component.get('v.recordId'),
                              "isLicense" : true,
                              "term" : component.find('license-terms').get('v.value')
                             });
            action.setCallback(this, function(response) {
                response.getReturnValue().pop();
                obsList.push(response.getReturnValue());
                component.set("v.obsItems", obsList);
                $A.util.toggleClass(component.find("spinner"), "slds-hide");
                window.location.reload();
            });
            $A.enqueueAction(action);
        } else {
            component.set('v.errors', 'Line(s) total should be 100');
        }
    },
    
    handleRowSelection: function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        console.log(event.getSource().getLocalId());
        component.set('v.selectedObsItems', selectedRows);
        component.set('v.hasRows', (selectedRows.length > 0 ? 'slds-show' : 'slds-hide'));
    },
    
    handleRowsDeletion: function(component, event, helper){
        var action = component.get("c.deleteOBSItems");
        console.log('in delete row');
        console.dir(component.get('v.selectedObsItems'));
        action.setParams({"itemsList": component.get('v.selectedObsItems')})
        action.setCallback(this, function(response) {
            helper.getObsItems(component, helper);
        });
        $A.util.toggleClass(component.find("spinner"), "slds-hide");
        $A.enqueueAction(action); 
    },                
    
    addRow: function(component, event, helper) {
        helper.addNewRow(component, event);
    },
    
    handleLicenseTerms: function(component, event, helper){
        component.set('v.isNonStandard' , component.find('license-terms').get('v.value') === 'Non - Standard' ? true : false);
        var cols = [
            {label: 'Milestone Name', fieldName: 'Name', type: 'text', editable: component.get('v.isNonStandard')},
            {label: 'Percentage %', fieldName: 'Line__c', type: 'number', editable: component.get('v.isNonStandard')},
            {label: 'Amount', fieldName: 'Line_Amount__c', type: 'currency', editable: component.get('v.isNonStandard')},
            {label: 'Line Drop Dead Date', fieldName: 'Line_Drop_Dead_Date__c', type: 'date-local', editable: true}
        ];
        component.set("v.tableCols", cols);
    },
    
})