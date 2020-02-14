({
	fetchSubscriptionHelper : function(component, event, helper) {
        var action = component.get("c.getSubscriptions");
        
        //Retrive URL contract Id
        action.setParams({"contractId" : component.get('v.contractId')});
        action.setCallback(this, function(response){
            var state = response.getState();
            //console.log(state);
            if (state == "SUCCESS") {
                var rows = response.getReturnValue();
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    row.Product_Set = row.SBQQ__Product__r.Product_Set__c;
                }
                //Retrieve related subscription records 
                component.set("v.subscriptions", rows);
                // Init the list for search output
                component.set("v.subscriptionsSearchList", rows);
            }
            else if (state == "ERROR") {
                var errorDetails = response.getError();
                component.set("v.showSuccess", false);
                component.set("v.errorMessage", errorDetails[0].message);   
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchRLFsubsTypesHelper : function(component, event, helper) {
        var action = component.get("c.getRLFsubscriptionTypes");
        
        action.setParams({"contractId" : component.get('v.contractId')});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                component.set("v.rLFoptions", response.getReturnValue());   
            }
            else if (state == "ERROR") {
                var errorDetails = response.getError();
                component.set("v.showSuccess", false);
                console.log(errorDetails[0].message);
        	}
        });
        $A.enqueueAction(action);
    }
})