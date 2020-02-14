({
	doInit : function(component, event, helper) {
		helper.getQuote(component);
	},

	handleQuoteSaveEdition: function (component, event, helper) {
        component.set("v.isProcessing",true);
        component.set("v.showSuccess", false);
        component.set("v.errorMessage", "");
        var action = component.get("c.updateQuote");
        var quoteRecord = component.get("v.quoteRecord");
        if(quoteRecord.Recurring_Fee_Payment_Terms__c !='' && quoteRecord.Recurring_Fee_Payment_Terms__c != null){
            action.setParams({"quoteRecord": component.get("v.quoteRecord")})
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    component.set("v.showSuccess", true);
                    component.set("v.errorMessage", "");
                }
                else if (state == "ERROR") {
                    var errorDetails = response.getError();
                    component.set("v.errorMessage", errorDetails[0].message);
                    component.set("v.showSuccess", false);
                }
                component.set("v.isProcessing",false);
            });
            $A.enqueueAction(action);
        }else{
            component.set("v.isProcessing",false);
            component.set("v.errorMessage", $A.get("$Label.c.Required_Field_Missing_Value"));
        }
    },
})