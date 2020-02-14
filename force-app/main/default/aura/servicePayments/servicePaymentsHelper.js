({
    getOBSItems : function(component, helper) {
        //$A.util.toggleClass(component.find("spinner"), "slds-hide");
        var action = component.get("c.getServiceItems");
        action.setParams({"quoteId": component.get('v.recordId')})
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var _results = response.getReturnValue();
                if(_results.length == 0) {
                	document.getElementById('service-payment').classList.add('slds-hide');
                }
                var SVTT_List = [], SVFP_List = [], SVPT_List = [];
                for(var i = 0; i < _results.length; i++){
                    switch (_results[i].Processing_Type__c) {
                        case 'SVTT':
                            SVTT_List.push(_results[i]);
                            break;
                        case 'SVFP':
                            SVFP_List.push(_results[i]);
                            break;
                        case 'SVPT':
                            SVPT_List.push(_results[i]);
                            break;
                    }
                }
                component.set("v.obsItems_SVTT", SVTT_List);
                component.set("v.obsItems_SVFP", SVFP_List);
                component.set("v.obsItems_SVPT", SVPT_List);
                console.log({SVTT_List, SVFP_List, SVPT_List});
                $A.util.toggleClass(component.find("spinner"), "slds-hide");
            }
            else {
                console.error(response.getError());
            }
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
                component.set("v.selectedValue", component.get('v.quote').Service_Payment_Terms__c);
                if(component.get('v.quote').Service_Payment_Terms__c == 'Non - Standard'){
                    component.set('v.isNonStandard', true);
                }
                
                var cols = [
                    {label: 'Milestone Name', fieldName: 'Name', type: 'text', editable: component.get('v.isNonStandard')},
                    {label: 'Percentage %', fieldName: 'Line__c', type: 'number', editable: component.get('v.isNonStandard')},
                    {label: 'Amount', fieldName: 'Line_Amount_for_Milestone__c', type: 'currency', editable: component.get('v.isNonStandard')},
                    {label: 'Drop Dead Date', fieldName: 'Line_Drop_Dead_Date__c', type: 'date-local',editable: true},
                    {label: 'Estimated Date', fieldName: 'Line_Estimated_Completion_Date__c', type: 'date-local', editable: component.get('v.isNonStandard')}
                ];
                component.set("v.tableCols", cols);
                this.getOBSItems(component, helper);
                //$A.util.toggleClass(component.find("spinner"), "slds-hide");
            }
            else {
                console.error(response.getError());
            }
            //$A.util.toggleClass(component.find("spinner"), "slds-hide");
        }));
        $A.enqueueAction(action);
    },
    
    addNewRow : function(component, event) {
        console.log('invoked ',event.getSource().getLocalId());
        var itemList;
        switch (event.getSource().getLocalId()) {
            case 'sp-svtt-add-btn':
                itemList = component.get('v.obsItems_SVTT');
                break;
            case 'sp-svfp-add-btn':
                itemList = component.get('v.obsItems_SVFP');
                break;
            case 'sp-svpt-add-btn':
                itemList = component.get('v.obsItems_SVPT');
                break;
        }
        
        console.log(itemList);
        
        itemList.push({
            'sobjectType': 'Opportunity_Billing_Schedule_Item__c',
            'Name': '',
            'Line__c':'',
            'Line_Amount__c': '',
            'Line_Drop_Dead_Date__c': '',
            'Line_Estimated_Completion_Date__c': ''
        });
        
        switch (event.getSource().getLocalId()) {
            case 'sp-svtt-add-btn':
                component.set("v.obsItems_SVTT", itemList);
                break;
            case 'sp-svfp-add-btn':
                component.set("v.obsItems_SVFP", itemList);
                break;
            case 'sp-svpt-add-btn':
                component.set("v.obsItems_SVPT", itemList);
                break;
        }
    },
    
})