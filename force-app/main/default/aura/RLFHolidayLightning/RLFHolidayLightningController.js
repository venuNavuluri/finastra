({
    doInit : function(component, event, helper) {
        
        component.set('v.columns', [
            {label: 'Subscription', fieldName: 'Name', type: 'text' },
            {label: 'Product Name', fieldName: 'SBQQ__ProductName__c', type: 'text'},   
            {label: 'Product Set', fieldName: 'Product_Set', type: 'text'},
            {label: 'RF Start Planned Date', fieldName: 'RF_Start_Planned_Date__c', type: 'date-local'},
            {label: 'CPI Uplift Review Date', fieldName: 'CPI_Uplift_Review_Date__c', type: 'date-local' }]);
        
        helper.fetchRLFsubsTypesHelper(component, event, helper);
        helper.fetchSubscriptionHelper(component, event, helper);    
        
    },
    
    handleSearchRLFtypes: function (component, event, helper) {
        var searchFilter = component.get("v.filterRLFtypes");
        var subscriptionsList = component.get("v.subscriptions");
        var subscriptionsSearchList = subscriptionsList;
        if(searchFilter != ""){ 
            subscriptionsSearchList = subscriptionsList.filter(row => (searchFilter == row.Product_Set));
        }
        component.set("v.showSuccess", false);
        component.set("v.errorMessage", "");   
        component.set("v.subscriptionsSearchList", subscriptionsSearchList);
        
    },
    
    retainSelectedRows: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        //Save the selected rows into rSelectedRows variable
        component.set("v.rSelectedRows",selectedRows);
        component.set("v.showSuccess", false);
        component.set("v.errorMessage", "");
    },
    
    handleSubSaveEdition: function (component, event, helper) {    
    
        //Retrieve the selected rows        
        var selectedRows;
        component.set("v.showSuccess", false);
        component.set("v.errorMessage", "");
        component.set("v.isLoading", true);
        //Retrieve the new RFL date
        var newRLFDate = component.get('v.newRLFDate');
        //Retrieve CPI Uplift Start Date
        var newCPIUpliftDate = component.get('v.newCPIUpliftDate');            
        var subscriptionsSearchList = component.get('v.subscriptionsSearchList');
        if(newRLFDate != null || newCPIUpliftDate != null){
            //Retrieve the selected rows  
            selectedRows = component.get('v.rSelectedRows');
            for (var i = 0; i < selectedRows.length; i++) { 
                if(newRLFDate != null)
                    selectedRows[i].RF_Start_Planned_Date__c = newRLFDate;
                if(newCPIUpliftDate != null)
                    selectedRows[i].CPI_Uplift_Review_Date__c = newCPIUpliftDate;
            }
        }else{
            selectedRows = [];
        }
        //Call out the saveSubscriptions method from the apex controller
        var action = component.get("c.saveSubscriptions");
        //Set parameters saveSubscriptions parameters
        action.setParams({"subscriptionsToSaveList" : selectedRows});    
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.isLoading", false);
            if (state == "SUCCESS") {
                component.set("v.showSuccess", true);
                component.set("v.errorMessage", "");
                window.location.reload();
            }
            else if (state == "ERROR") {
                var errorDetails = response.getError();
                component.set("v.errorMessage", errorDetails[0].message);
                component.set("v.showSuccess", false);
            }
        });
        $A.enqueueAction(action);
       
    },
    returnToContract: function (component, event, helper) {
        window.location = '/'+component.get("v.contractId");
        
    },
    
    
    
    
    })