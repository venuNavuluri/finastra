({
    handleInit: function (cmp, event, helper) {
        console.log('handleInit'); 
        console.log(cmp.get("v.recordId"));
        
        var action = cmp.get("c.getInfo");
        
        action.setParams({billingGroupId: cmp.get("v.recordId")});
        action.setCallback
        (
            this, function (response) 
            {
                var state = response.getState();
                if (state == 'SUCCESS') 
                {
                    console.log('Response');
                    console.log(response.getReturnValue());
                    var data = response.getReturnValue();
                    //cmp.set("v.contr", data.contr);
                    cmp.set("v.showError", data.showError);
                    cmp.set("v.showSuccess", data.showSuccess);
                    cmp.set("v.showConfirm", data.showConfirm);
                    cmp.set("v.showWarning", data.showWarning); 
                    cmp.set("v.warningMessage", data.warningMessage);
                    cmp.set("v.errorMessage", data.errorMessage);  
                    cmp.set("v.bodyMessage", data.successMessage);   
                    cmp.set("v.returnId", cmp.get("v.recordId"));
                    cmp.set("v.isLoading", false);
                } else 
                {
                    cmp.set("v.showConfirm", false);                   
                    cmp.set("v.isLoading", false);
                    cmp.set("v.showError", true);
                    cmp.set("v.showSuccess", false); 
                    cmp.set("v.errorMessage", response.getError());   
                    cmp.set("v.returnId", cmp.get("v.recordId"));
                    console.log('======> error: ',response.getError());
                }
            }
        );
        $A.enqueueAction(action);
    },

    createRLF: function (cmp, event, helper) {
        console.log('handleInit'); 
        console.log(cmp.get("v.recordId"));
		cmp.set("v.isLoading", true);        
        var action = cmp.get("c.execute");
        
        action.setParams({billingGroupId: cmp.get("v.recordId")});
        action.setCallback
        (
            this, function (response) 
            {   
                var state = response.getState();
                if (state == 'SUCCESS') 
                {
                    console.log('Response');
                    console.log(response.getReturnValue());
                    var data = response.getReturnValue();
                    cmp.set("v.returnId", cmp.get("v.recordId"));                   
                    //cmp.set("v.contr", data.contr);
                    cmp.set("v.showError", data.showError);
                    cmp.set("v.showSuccess", data.showSuccess); 
                    cmp.set("v.errorMessage", data.errorMessage);  
                    cmp.set("v.successMessage", data.successMessage); 
                    cmp.set("v.showWarning", data.showWarning); 
                    cmp.set("v.warningMessage", data.warningMessage);                     
                    cmp.set("v.showConfirm", false);  
                    cmp.set("v.isLoading", false);
                } else 
                {
                    cmp.set("v.isLoading", false);
                    cmp.set("v.showError", true);
                    cmp.set("v.showSuccess", false); 
                    cmp.set("v.showConfirm", false);  
                    cmp.set("v.errorMessage", response.getError());   
                    cmp.set("v.returnId",cmp.get("v.recordId"));
                    console.log('======> error: ',response.getError());
                }
            }
        );
        $A.enqueueAction(action);
    },
    returnToRecord: function (cmp, helper) {
        window.location = '/'+cmp.get("v.returnId");
    }
})