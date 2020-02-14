({
    
    doInit : function(component, event, helper) {
        helper.getQuote(component, helper);
    },
    
    handleSaveEdition: function (component, event, helper) {
        //$A.util.toggleClass(component.find("spinner"), "slds-hide");
        var draftValues = event.getParam("draftValues");
        
        var obsList;
        switch (event.getSource().getLocalId()) {
            case 'sp-svtt':
                obsList = component.get('v.obsItems_SVTT');
                break;
            case 'sp-svfp':
                obsList = component.get('v.obsItems_SVFP');
                break;
            case 'sp-svpt':
                obsList = component.get('v.obsItems_SVPT');
                break;
        }
        
        var total = 0; var tempVal = 0;
        for(var i = 0; i < obsList.length; i++){
            if(!isNaN(obsList[i].Line__c)){
                tempVal = parseFloat(obsList[i].Line__c);
            }
            for(var j = 0; j < draftValues.length; j++){
                if(draftValues[j].Id == obsList[i].Id && !isNaN(draftValues[j].Line__c)){
                    tempVal = parseFloat(draftValues[j].Line__c);
                }
            }
            if(tempVal > 0) total += tempVal;
        }
        tempVal = 0;
        for(var j = 0; j < draftValues.length; j++){
            if(draftValues[j].Id.length < 15 && !isNaN(draftValues[j].Line__c)){
                tempVal += parseFloat(draftValues[j].Line__c);
            }
        }
        
        total += tempVal;
        // console.log('total 2', total);
        
        if( total == 100.00){
            component.set('v.errors', null);
            var action = component.get("c.saveOBSItems");
            action.setParams({"itemsList" : draftValues, 
                              "obsId" : obsList[0].Opportunity_Billing_Schedule__c,
                              "quoteId" : component.get('v.recordId'),
                              "isLicense" : false,
                              "term" : component.find('service-terms').get('v.value')
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
            switch (event.getSource().getLocalId()) { 
                case 'sp-svtt':
                    component.set('v.errors_SVTT', 'Line(s) total should be 100');
                    break;
                case 'sp-svfp':
                    component.set('v.errors_SVFP', 'Line(s) total should be 100');
                    break;
                case 'sp-svpt':
                    component.set('v.errors_SVPT', 'Line(s) total should be 100');
                    break;
            }
        }
    },
    
    handleRowSelection: function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        switch (event.getSource().getLocalId()) {
            case 'sp-svtt':
                component.set('v.selected_SVTT', selectedRows);
                component.set('v.hasRows_SVTT', (selectedRows.length > 0 ? 'slds-show' : 'slds-hide'));
                break;
            case 'sp-svfp':
                component.set('v.selected_SVFP', selectedRows);
                component.set('v.hasRows_SVFP', (selectedRows.length > 0 ? 'slds-show' : 'slds-hide'));
                break;
            case 'sp-svpt':
                component.set('v.selected_SVPT', selectedRows);
                component.set('v.hasRows_SVPT', (selectedRows.length > 0 ? 'slds-show' : 'slds-hide'));
                break;
        }
    },
    
    handleRowsDeletion: function(component, event, helper){
        $A.util.toggleClass(component.find("spinner"), "slds-hide");
        var action = component.get("c.deleteOBSItems");
        var selectedItems;
        switch (event.getSource().getLocalId()) {
            case 'sp-svtt-del-btn':
                selectedItems = component.get('v.selected_SVTT');
                break;
            case 'sp-svfp-del-btn':
                selectedItems = component.get('v.selected_SVFP');
                break;
            case 'sp-svpt-del-btn':
                selectedItems = component.get('v.selected_SVPT');
                break;
        }
        action.setParams({"itemsList": selectedItems})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //helper.getObsItems(component, helper);
                $A.util.toggleClass(component.find("spinner"), "slds-hide");
                window.location.reload();
            } else {
                console.error('Deletion failed');
            }
        });
        
        $A.enqueueAction(action); 
    },                
    
    addRow: function(component, event, helper) {
        helper.addNewRow(component, event);
    },
    
    handleServiceTerms: function(component, event, helper){
        component.set('v.isNonStandard' , component.find('service-terms').get('v.value') === 'Non - Standard' ? true : false);
        var cols = [
            {label: 'Milestone Name', fieldName: 'Name', type: 'text', editable: component.get('v.isNonStandard')},
            {label: 'Percentage %', fieldName: 'Line__c', type: 'number', editable: component.get('v.isNonStandard')},
            {label: 'Amount', fieldName: 'Line_Amount_for_Milestone__c', type: 'currency', editable: component.get('v.isNonStandard')},
            {label: 'Drop Dead Date', fieldName: 'Line_Drop_Dead_Date__c', type: 'date-local',editable: true},
            {label: 'Estimated Date', fieldName: 'Line_Estimated_Completion_Date__c', type: 'date-local', editable: component.get('v.isNonStandard')}
        ];
        component.set("v.tableCols", cols);
    },
})