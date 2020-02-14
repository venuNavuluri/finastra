({
	getQuote: function(component){
        component.set("v.isProcessing",true);
        var action = component.get("c.getQuote");
		//Retrieve quote details
		action.setParams({"quoteId": component.get("v.recordId")});
        action.setCallback(this, function(response){
           //console.log(component.find("spinner"));
            $A.util.toggleClass(component.find('spin'), "slds-hide");
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.quoteRecord", response.getReturnValue());
            }
            else {
                console.error(response.getError());
            }
            component.set("v.isProcessing",false);
        });
        $A.enqueueAction(action);
	},
	
})